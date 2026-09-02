#!/usr/bin/env bash
# Rotate the gitlab.aws.dev Personal Access Token, with no human input required.
#
# Reads the current token from the macOS keychain, calls GitLab's self-rotate
# endpoint (needs the self_rotate scope), stores the replacement back in the
# keychain, and updates .kiro/credentials.json with the new id and expiry.
#
# The token value is never printed and never written to a file.
#
# Why this is not a one-line curl: gitlab.aws.dev sits behind an AWS ELB that
# redirects unauthenticated requests to idp.federate.amazon.com. A bare API call
# never reaches GitLab, and following the redirect turns a POST into a request the
# IdP rejects with 405. So we do it in two steps: a GET with the Midway cookie to
# obtain the ELB session cookie, then the POST with that session cookie and no
# redirect following.
#
# Usage:  .kiro/scripts/rotate-gitlab-pat.sh [--days N] [--check]
#           --days N   lifetime for the new token (default 90)
#           --check    report current expiry and exit without rotating

set -euo pipefail

DAYS=90
CHECK_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)  DAYS="$2"; shift 2 ;;
    --check) CHECK_ONLY=1; shift ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATE="$REPO/.kiro/credentials.json"
SERVICE="gitlab.aws.dev-pat"
ACCOUNT="davelau"
HOST="https://gitlab.aws.dev"

command -v security >/dev/null || { echo "ERROR: macOS 'security' not found" >&2; exit 1; }
[[ -f "$HOME/.midway/cookie" ]] || { echo "ERROR: no ~/.midway/cookie — run 'mwinit' first" >&2; exit 1; }

if [[ $CHECK_ONLY -eq 1 ]]; then
  python3 - "$STATE" <<'PY'
import json, sys, datetime
d = json.load(open(sys.argv[1]))
for c in d["credentials"]:
    exp = c.get("expires")
    if not exp: continue
    left = (datetime.date.fromisoformat(exp) - datetime.date.today()).days
    print(f"{c['name']}: expires {exp} ({left} day(s) left), token id {c.get('token_id')}")
PY
  exit 0
fi

TOKEN="$(security find-generic-password -a "$ACCOUNT" -s "$SERVICE" -w 2>/dev/null || true)"
if [[ -z "$TOKEN" ]]; then
  echo "ERROR: no token in keychain (service '$SERVICE', account '$ACCOUNT')." >&2
  echo "Create one at $HOST/-/user_settings/personal_access_tokens with the 'api'" >&2
  echo "and 'self_rotate' scopes, then store it with:" >&2
  echo "  security add-generic-password -a $ACCOUNT -s $SERVICE -w '<token>' -U" >&2
  exit 1
fi

JAR="$(mktemp "${TMPDIR:-/tmp}/gljar.XXXXXX")"
cleanup() { rm -f "$JAR"; }
trap cleanup EXIT

cp "$HOME/.midway/cookie" "$JAR"

# Step 1 — get past the SSO proxy and capture the ELB session cookie.
code="$(curl -s -L -b "$JAR" -c "$JAR" -H "PRIVATE-TOKEN: $TOKEN" \
        -o /dev/null -w '%{http_code}' "$HOST/api/v4/user")"
if [[ "$code" != "200" ]]; then
  echo "ERROR: could not authenticate to GitLab (HTTP $code)." >&2
  echo "If 401, the token is expired or revoked and cannot self-rotate — create a new one." >&2
  echo "If 302, the Midway cookie is stale — run 'mwinit' and retry." >&2
  exit 1
fi

# Step 2 — rotate. No -L: the POST must not be redirected.
EXPIRES="$(python3 -c "import datetime,sys; print((datetime.date.today()+datetime.timedelta(days=int(sys.argv[1]))).isoformat())" "$DAYS")"
RESP="$(mktemp "${TMPDIR:-/tmp}/glrot.XXXXXX")"
trap 'rm -f "$JAR" "$RESP"' EXIT

code="$(curl -s -b "$JAR" -H "PRIVATE-TOKEN: $TOKEN" -H 'Content-Type: application/json' \
        -X POST --data '' -o "$RESP" -w '%{http_code}' \
        "$HOST/api/v4/personal_access_tokens/self/rotate?expires_at=$EXPIRES")"
if [[ "$code" != "200" && "$code" != "201" ]]; then
  echo "ERROR: rotation failed (HTTP $code)" >&2
  head -c 300 "$RESP" >&2; echo >&2
  exit 1
fi

# Store the replacement and update state. Value stays out of stdout and off disk.
python3 - "$RESP" "$STATE" "$SERVICE" "$ACCOUNT" <<'PY'
import json, subprocess, sys, datetime
resp, state_path, service, account = sys.argv[1:5]
d = json.load(open(resp))
new = d["token"]

subprocess.run(["security", "add-generic-password", "-a", account, "-s", service,
                "-w", new, "-U", "-D", "GitLab PAT (auto-rotated)"], check=True)

state = json.load(open(state_path))
for c in state["credentials"]:
    if c.get("keychain_service") == service:
        c["token_id"] = d["id"]
        c["token_name"] = d.get("name", c.get("token_name"))
        c["expires"] = d.get("expires_at")
        c["last_rotated"] = datetime.date.today().isoformat()
        if d.get("scopes"):
            c["scopes"] = d["scopes"]
with open(state_path, "w") as f:
    json.dump(state, f, indent=2)
    f.write("\n")

print("Rotation complete.")
print(f"  token id : {d['id']}")
print(f"  expires  : {d.get('expires_at')}")
print(f"  scopes   : {', '.join(d.get('scopes', []))}")
print(f"  value    : {new[:9]}... (length {len(new)}) - stored in keychain, not printed")
print(f"  state    : {state_path} updated")
PY

echo "Old token is revoked automatically by the rotate call."
echo "Commit the updated .kiro/credentials.json so the new expiry travels with the repo."
