# Requirements — Merge Forks, Six Paths, Questionnaire-Grade Depth

> **Note on location.** This spec lives under `.kiro/`, which is listed in
> `.git/info/exclude`. These three documents are therefore **untracked working
> artifacts**, not committed deliverables. The committed deliverables of this
> effort are `POWER.md`, `README.md`, `steering/*.md` and `MIGRATION-NOTES.md`.

## Context

Two divergent copies of the "Legacy App Modernization Analyzer" Kiro Power exist:

| Fork | Location | Status |
|---|---|---|
| **B** (base) | `kiro-net-mod-analyzer/legacy-app-modernization-analyzer/` | git-tracked, clean, pushed to `gitlab.aws.dev` + `github.com/davidcslau/enterprise-modernization-analyzer`, `version: 2.0.0` |
| **A** (fork) | `Code/atx-txfrm/new-analyzer/` | untracked, currently the *installed* power, no version field, backed up at `~/analyzer-fork-backup-20260901` |
| **C** (monolith) | `Code/atx-app-mod-analyzer/` | out of scope — do not touch |

B carries 5 paths and the stronger orchestration layer (ordered detection with
negative signals, ambiguity rules, user override). A carries a sixth path B
lacks (.NET → Java Spring Boot Reactive) and is additively ahead on four shared
files. Neither fork has any front-end/SPA concept, any WildFly/JBoss path, or
any Oracle → PostgreSQL workstream.

Two real customer qualification questionnaires define the depth of analysis now
expected of the generated report. They are **inputs to the analysis, not
outputs**.

## Verified ground truth

Established by inspection before any edit, and recorded here because several
requirements depend on it:

1. `.git/info/exclude` contains `.DS_Store`, `.kiro/*`, `ref/*`, `deploy/`.
   Only `POWER.md`, `README.md`, `mcp.json` and `steering/` are tracked
   (confirmed against `git ls-files`).
2. Both `.kiro/hooks/*.kiro.hook` files are `askAgent` hooks on `fileEdited`
   matching `POWER.md`, `README.md`, `mcp.json`, `steering/*.md` and
   `steering/**/*.md`. Both match `README.md`, so the README hook retriggers
   itself.
3. A's four deltas over B are purely additive — verified by `diff -u`. No
   conflicting rewrites.
4. `cobol-to-java.md`, `report-structure.md`, `evaluation-framework.md` and
   `aws-target-services.md` are byte-identical across A and B.
5. Three of B's steering files are currently `inclusion: always`
   (`aws-target-services.md`, `evaluation-framework.md`, `report-structure.md`)
   and one is `inclusion: fileMatch` (`j2ee-to-springboot-reactive.md`).
6. `report-structure.md` has exactly 11 numbered report sections; "Generate
   exactly 3 distinct pathways" sits at line 203–204; rule 14 forbids ASCII art.
7. Both named defects are real: `dotnet-to-aws.md` carries the same decision-tree
   Mermaid block at two places, and `evaluation-framework.md` forbids ASCII art
   at line ~158 then draws a box-drawing diagram at line ~194.
8. Both questionnaires confirm the distilled criteria. The .NET workbook names
   **"Kiro Legacy App Modernizer"** as the tool for as-is architecture analysis
   (Tab 1, ref 3.1) and tags rows `Code analysis` / `SCC input` /
   `Code analysis + SCC`. The J2EE workbook lists **JBoss/WildFly** as a
   first-class app server option (row 3.02), which independently justifies the
   new WildFly path.

## Functional requirements

### R1 — Single merged power, B as base

- **R1.1** All content merges into B. Fork A is never edited.
- **R1.2** A's `steering/dotnet-to-springboot.md` is imported **body only**;
  A's front matter is never copied.
- **R1.3** That import is committed on its own, before any other change, because
  the file has never existed in any git history.
- **R1.4** A's four additive deltas are applied to B.

### R2 — Seven steering-file rows across six source families

| # | Source | Target | Steering file |
|---|---|---|---|
| 1 | .NET Framework | .NET 8 **or .NET 10** + AWS | `dotnet-to-aws.md` |
| 2 | .NET Framework | Java Spring Boot + React/Vue + AWS | `dotnet-to-springboot.md` |
| 3 | J2EE — IBM WebSphere | Spring Boot + React/Vue + AWS | `websphere-to-springboot.md` |
| 4 | J2EE — Oracle WebLogic | Spring Boot + React/Vue + AWS | `weblogic-to-springboot.md` |
| 5 | J2EE — Red Hat WildFly / JBoss EAP | Spring Boot + React/Vue + AWS | `wildfly-to-springboot.md` **(new)** |
| 6 | Java SE 8 / plain Java | Spring Boot 3.x + Java 17/21 + React/Vue + AWS | `java-to-springboot.md` |
| 7 | COBOL / Mainframe | Java Spring Boot + React/Vue + AWS | `cobol-to-java.md` |

- **R2.1** Rows 3–5 present as one **J2EE family** in the paths table, with three
  vendor steering files underneath sharing `j2ee-to-springboot-reactive.md`.
  They stay separate files — vendor APIs differ enough to warrant it.
- **R2.2** Three new cross-cutting steering files: `wildfly-to-springboot.md`,
  `frontend-to-spa.md`, `oracle-to-postgresql.md`.

### R3 — Loading mechanism

- **R3.1** Every steering file is `inclusion: manual`. No exceptions.
- **R3.2** `POWER.md` Step 2 is the single authoritative dispatch table, naming
  exactly which files to load for each detected source + target combination, in
  order.
- **R3.3** No `fileMatch` and no `#[[file:...]]` anywhere in the power. The
  existing `fileMatchPattern` on `j2ee-to-springboot-reactive.md` is removed and
  the file is dispatched from `POWER.md` instead.
- **R3.4** No steering file is orphaned — every file is reachable from the
  dispatch table.

**Consequence for R1.4:** A's `websphere` and `weblogic` deltas introduce
`#[[file:j2ee-to-springboot-reactive.md]]`, which R3.3 forbids. The *sections*
are applied; the reference mechanism is replaced with a plain-text pointer to
POWER.md dispatch. Similarly A's new front-matter comment on the j2ee file is
reworded to drop its `#[[file:]]` mention. This is the only adaptation made to
A's four deltas.

### R4 — Two-dimensional detection

- **R4.1** Source detection runs in this order, which is load-bearing:
  `.NET → WebSphere → WebLogic → WildFly → plain Java → COBOL`.
- **R4.2** The plain-Java detector stays **after** all three app servers, with
  its existing negative signals extended to exclude WildFly markers.
- **R4.3** A target prompt follows source detection:
  - .NET → (a) .NET 8, (b) .NET 10, (c) Java Spring Boot + SPA
  - any Java / J2EE / COBOL source → target is Spring Boot; ask front-end:
    React, Vue, or backend-only (no front-end rewrite in scope)
- **R4.4** No default is assumed for either dimension. If the user's opening
  message already stated a target, the prompt is skipped.
- **R4.5** B's existing ambiguity rules and explicit user override survive.

### R5 — Questionnaire depth: universal criteria

`evaluation-framework.md` must make every path detect and reason about: exact
runtime version and vendor (including JDK vendor, because Oracle JDK licensing
changed post-8); build tooling, clean-checkout buildability and full build time;
LOC, module count and actual layering; **where business logic physically lives**;
third-party and commercial dependencies with name/version/licence/vendor and
target-compatible availability; auth mechanism and blast radius; data access
technology; session state and caching; integration inventory with protocol,
direction and contract documentation; architectural seams; existing automated
tests and framework; deployment artifact today and target; config and secrets
handling; dead code, duplication and existing static-analysis output; native
code (JNI, `.so`/`.dll`, OS-specific).

- **R5.1** A non-building baseline is a **gating finding**, not a footnote.
- **R5.2** In-process session state is called out as blocking containerization
  and horizontal scaling on every path.
- **R5.3** Third-party dependencies are stated plainly as where most
  modernization programmes stall.

### R6 — Questionnaire depth: honesty rule

`evaluation-framework.md` gains an explicit rule that the following cannot be
derived from source, must be named as open questions requiring customer input,
and must never be guessed at: business criticality; named owner / architect /
dev lead; actively-developed vs frozen; end-state vision; disposition;
decommission plans; blast radius; nominated POC workflow; hard deadlines;
regulatory and data-residency constraints; developer availability and skill;
NFRs (concurrent users, TPS, latency SLA, availability); environment
availability; data classification (PII / payment / regulated); AI model
approvals and code-egress permission; sign-off authorities.

### R7 — Questionnaire depth: .NET

Into `dotnet-to-aws.md` and `dotnet-to-springboot.md`: application type as the
dominant effort driver (Web Forms and WCF hardest, Web API and MVC easiest;
WinForms, WPF, Windows Service, Console and scheduled jobs each treated);
primary language and mixed-language split, with **VB.NET called out as material
friction** to both AI-assisted transformation and AWS Transform; Windows lock-in
exhaustively as its own findings cluster (COM/COM+, P/Invoke, native Windows
API, registry, MSMQ, IIS modules and handlers, GAC assemblies, `System.Drawing`,
Crystal Reports, RDLC/SSRS, Office interop, 32-bit-only components, unmanaged
DLLs with lost source, UNC shares and local paths, Windows scheduled tasks);
Visual Studio version and build toolchain; SQL Server footprint with version,
edition and counts of stored procedures, functions, triggers and SSIS packages.

### R8 — Questionnaire depth: Java / J2EE

Into `websphere-`, `weblogic-`, `wildfly-` and `java-to-springboot.md`:
application server and version with its javax/jakarta position (Tomcat 8.5/9.x
javax → Spring Boot 2.x only; Tomcat 10.0/10.1 jakarta → Spring Boot 3.x
enabled), which decides whether a Java 8→17 then Boot 2→3 two-step is
unavoidable; framework stack and migration cost (Spring MVC upgrades most
readily, Struts 1/2 and JSF need materially more rewriting); J2EE/Jakarta API
usage (EJB — **2.x flagged as the hardest single construct**, JMS, JPA, JTA,
JNDI, JAX-RS, JAX-WS/SOAP, CDI); proprietary vendor APIs as a **first-class
findings cluster**, being the questionnaire's stated **#1 migration risk**;
removed-API usage (`sun.*`, `javax.xml.bind`, `javax.activation`, CORBA);
Java-8-compiled libraries reaching into internals removed in Java 9+.

### R9 — Questionnaire depth: COBOL

Into `cobol-to-java.md`: the universal criteria mapped onto mainframe
equivalents — COBOL dialect and compiler, CICS coupling depth, DB2 vs VSAM
split, JCL/scheduler coupling, RACF/ACF2/Top Secret as the auth finding.

### R10 — The two scope asymmetries

- **R10.1** .NET: database migration is **explicitly OUT of scope**; apps stay on
  SQL Server and the target design deliberately avoids database change. B's
  current unconditional SQL Server → Aurora PostgreSQL recommendation
  contradicts this and must be fixed.
- **R10.2** J2EE: Oracle → PostgreSQL is **IN scope** and is a full workstream.
- **R10.3** Neither is ever assumed. Detect the database, report the footprint,
  and state the scope question explicitly.

### R11 — .NET target and pathway modelling

- **R11.1** .NET 10 is selectable alongside .NET 8, covering directly that .NET
  8's support window ends before a long programme completes.
- **R11.2** The 3.x → 4.x pre-upgrade step (AWS Transform Custom) is modelled,
  with paths stated explicitly as `3→10`, `4→10` and `3→4→10`, and each hop
  flagged as adding transformation-defect surface.
- **R11.3** Windows containers appear as a lower-risk interim hop, distinct from
  full Linux/Graviton containerization which requires complete Windows-dependency
  removal.

### R12 — Front-end / SPA dimension

New `frontend-to-spa.md`, dispatched for `dotnet-to-springboot`, all three J2EE
paths, `java-to-springboot` and `cobol-to-java`. Covers: current front-end
detection and screen inventory; **whether a REST API already exists** as the
dominant sizing question; full SPA vs hybrid with consequences; business logic
in the view layer, quantified; session and auth interaction; what does not port
cleanly as its own risk class; target-side patterns; COBOL BMS/3270 mapping.

- **R12.1** React vs Vue is **user input, never an analyzer recommendation**. The
  analyzer detects the current front-end, sizes the rewrite, and accepts the
  target as given. It never compares React and Vue or advocates either.
- **R12.2** "SPA drops in against an existing REST API" and "full front-end
  rewrite plus a business-logic extraction workstream" are materially different
  efforts and the report must not conflate them.

### R13 — Oracle → PostgreSQL workstream

New `oracle-to-postgresql.md`, dispatched only when Oracle → PostgreSQL is
confirmed in scope. Covers Oracle version/edition/RAC and Enterprise-only
features with PostgreSQL workarounds; PL/SQL inventory with counts and volume;
Oracle-specific SQL constructs; Oracle-proprietary features; data type mappings;
data access impact; sizing and downtime window; Oracle licence elimination as a
business driver.

- **R13.1** The empty-string-is-NULL semantic difference is flagged as a **silent
  behaviour-change risk**, not a syntax issue.

### R14 — Defect fixes

- **R14.1** `dotnet-to-aws.md`: merge the duplicated decision-tree section into
  one, keeping the single Mermaid diagram **and the first copy's richer
  "Decision Tree Mapping Instructions" table** plus its ✅/❌ path-highlighting
  guidance. The second block's wording is reviewed for anything worth folding in
  rather than simply deleted.
- **R14.2** `evaluation-framework.md`: convert the box-drawing diagram to
  Mermaid, preserving semantics — modernized app ↔ REST/gRPC ↔ EC2 legacy
  component host containing an API wrapper service.

### R15 — Versioning and metadata

`POWER.md` front matter bumps to `3.0.0`; `description` and `keywords` gain
WildFly, JBoss, React, Vue, SPA, PostgreSQL, Oracle and .NET 10.

### R16 — atx monolith

- **R16.1** `atx-app-mod-analyzer/atx-txfrm-defn/transformation_definition.md`
  is **not** regenerated. It uses a different 13-section report structure with
  COBOL-specific sections promoted, so regenerating would silently revert that
  restructuring.
- **R16.2** `MIGRATION-NOTES.md` is written in the repo root listing every change
  needing mirroring into the monolith, section by section.
- **R16.3** `atx custom def publish` is not run.

## Invariants

- **I1** Report output filename stays `yymmddhhmm_MODERNIZATION_REPORT.md` (UTC).
- **I2** Exactly 3 ranked pathways per report.
- **I3** No ASCII art — all diagrams Mermaid, every architecture diagram with a
  colour legend. No dollar amounts. No hour or day effort estimates. No
  file/line counts used as effort proxies.
- **I4** `report-structure.md` stays AUTHORITATIVE and keeps its **11 sections**.
  New analysis depth enriches existing sections — principally 3 (Visual
  Architecture State), 4 (Critical Findings Matrix), 5 (Proprietary Dependency
  Analysis) and 6 (Database Analysis). No sections added, none renumbered, both
  quality checklists left structurally alone.
- **I5** `.kiro/steering/analyzer-ground-rules.md` is not edited — it is
  git-excluded and unrecoverable. Its rules still bind: frame findings as
  evidence for modernization specialists; no go/no-go decision tables; no
  failure case studies; always direct readers to AWS Modernization Specialists
  or authorized partners.
- **I6** When the user has chosen Java, **never** propose a ".NET 8 first, then
  Java" bridge pathway. All three report pathways must terminate in Java.
- **I7** Additive edits where possible. No wholesale reformatting or rewriting of
  existing steering.
- **I8** Fork A is not modified. `atx-app-mod-analyzer/` is not touched. Nothing
  is pushed.

## Process requirements

- **P1** Work on branch `feat/merge-six-paths`.
- **P2** Both hooks are disabled before any edit and re-enabled in Phase 6. The
  toggle is untracked, so restoring it is a tracked obligation of this spec.
- **P3** Commit after each phase.
- **P4** Hard stop at CHECKPOINT 1 (after the merge) and CHECKPOINT 2 (after the
  new content) for user review.
- **P5** No backup step — `~/analyzer-fork-backup-20260901` exists and is
  verified.

## Out of scope

- Adding a questionnaire section to the report, or filling in answer tables. The
  questionnaires shape *what the analyzer detects and reasons about*, nothing
  more.
- Recommending between React and Vue, or between .NET 8 and .NET 10, or between
  full SPA and hybrid. The analyzer sizes and consequences each option; the
  customer chooses.
- Any change to report section numbering or count.
