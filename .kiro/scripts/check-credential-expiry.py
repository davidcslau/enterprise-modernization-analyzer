#!/usr/bin/env python3
"""Warn about credentials nearing expiry. Run at session start by a Kiro hook.

Silent when everything is healthy, so it adds no noise to a normal session.
Speaks up only when a credential is inside its rotate_within_days window, has
already expired, or has gone missing from the keychain.

Always exits 0 — this warns, it never blocks a session.
Reads .kiro/credentials.json. Never reads or prints secret values.
"""

import datetime
import json
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parents[2]
STATE = REPO / ".kiro" / "credentials.json"


def keychain_present(service: str, account: str) -> bool:
    """True if the secret still exists. Value is discarded, never printed."""
    try:
        subprocess.run(
            ["security", "find-generic-password", "-a", account, "-s", service, "-w"],
            capture_output=True, check=True, timeout=10,
        )
        return True
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return False


def main() -> int:
    if not STATE.exists():
        return 0
    try:
        creds = json.loads(STATE.read_text()).get("credentials", [])
    except (json.JSONDecodeError, OSError):
        return 0

    today = datetime.date.today()
    alerts = []

    for c in creds:
        name = c.get("name", "unnamed credential")
        raw = c.get("expires")
        window = int(c.get("rotate_within_days", 21))
        svc, acct = c.get("keychain_service", ""), c.get("keychain_account", "")
        cmd = c.get("rotate_command", "(no rotate command recorded)")

        missing = svc and acct and not keychain_present(svc, acct)
        if missing:
            alerts.append(
                f"- {name}: NOT FOUND in the keychain (service '{svc}', account '{acct}').\n"
                f"  It may have been deleted, or this is a fresh machine. Re-create it, then run: {cmd}"
            )

        if not raw:
            continue
        try:
            expires = datetime.date.fromisoformat(raw)
        except ValueError:
            continue

        left = (expires - today).days
        if left < 0:
            alerts.append(
                f"- {name}: EXPIRED {abs(left)} day(s) ago (on {raw}).\n"
                f"  Self-rotation will no longer work — an expired token cannot rotate itself.\n"
                f"  A new token must be created manually at\n"
                f"  https://gitlab.aws.dev/-/user_settings/personal_access_tokens"
            )
        elif left <= window:
            alerts.append(
                f"- {name}: expires in {left} day(s), on {raw}.\n"
                f"  ROTATE NOW, before it expires — run: {cmd}\n"
                f"  Do not wait to be asked, and do not ask the user to paste a token."
            )

    if not alerts:
        return 0

    print("=" * 72)
    print("CREDENTIAL EXPIRY WARNING — action required by you, the agent")
    print("=" * 72)
    print("\n".join(alerts))
    print()
    print("Rotation is fully automated and needs no human input. Do it proactively,")
    print("tell the user it is done, and never print a token value into the chat.")
    print("=" * 72)
    return 0


if __name__ == "__main__":
    sys.exit(main())
