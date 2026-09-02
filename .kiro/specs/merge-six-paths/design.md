# Design — Merge Forks, Six Paths, Questionnaire-Grade Depth

## 1. Architecture of the power after the merge

The power becomes a **two-dimensional dispatcher over a flat steering library**.
Before this change, source platform alone selected one steering file, and three
files loaded unconditionally via `inclusion: always`. After it, source platform
and target platform *together* select an ordered list of steering files, and
nothing loads implicitly.

```
POWER.md
├── Step 1  Detect SOURCE           (ordered, negative signals, ambiguity rules)
├── Step 1b Prompt for TARGET       (per source; skipped if already stated)
├── Step 2  DISPATCH TABLE          (source + target → ordered file list)
└── Step 3  Execute analysis

steering/                       role
├── report-structure.md         AUTHORITATIVE report format — always dispatched
├── evaluation-framework.md     universal criteria + honesty rule — always dispatched
├── aws-target-services.md      AWS mappings — always dispatched
├── dotnet-to-aws.md            source+target leaf
├── dotnet-to-springboot.md     source+target leaf
├── websphere-to-springboot.md  source leaf ─┐
├── weblogic-to-springboot.md   source leaf ─┼── share j2ee-to-springboot-reactive.md
├── wildfly-to-springboot.md    source leaf ─┘
├── java-to-springboot.md       source leaf
├── cobol-to-java.md            source leaf
├── j2ee-to-springboot-reactive.md   shared target-architecture module
├── frontend-to-spa.md              cross-cutting dimension (conditional)
└── oracle-to-postgresql.md         cross-cutting dimension (conditional)
```

### 1.1 Why `inclusion: manual` everywhere

Three files are currently `inclusion: always` and one is `fileMatch`. Both
mechanisms are being removed in favour of explicit dispatch, for reasons that are
mechanical rather than stylistic:

- `always` loads a file into *every* Kiro session in the workspace, not just
  modernization analyses, which is both wasteful and a source of cross-talk.
- `fileMatch` on `j2ee-to-springboot-reactive.md` matches on the *steering file
  path itself* (`**/websphere-to-springboot.md`), which only fires when the user
  happens to open that steering file in the editor — not when the analyzer reads
  it. It has therefore never reliably loaded during an actual analysis. This is
  the concrete reason the fixed decision mandates explicit instruction.
- `#[[file:...]]` transclusion has the same reliability problem and is removed
  for the same reason.

The dispatch table replaces all three. Universality is preserved by listing
`report-structure.md`, `evaluation-framework.md` and `aws-target-services.md` in
**every** row of the table rather than by relying on `always`.

### 1.2 Adaptation of A's four deltas

Three of A's four deltas apply verbatim. One class needs adaptation:

| Delta | Applied as |
|---|---|
| `dotnet-to-aws.md` — "Analyzer Mission" section | verbatim |
| `websphere-to-springboot.md` — "Shared J2EE" section | section kept, `#[[file:]]` line replaced with a plain-text pointer to POWER.md dispatch |
| `weblogic-to-springboot.md` — same | same |
| `j2ee-to-springboot-reactive.md` — front matter → `manual` | front matter applied; A's HTML comment reworded to describe dispatch rather than `#[[file:]]` |

This is the only deviation from "apply A's deltas as-is", and it is forced by
R3.3. Semantics are unchanged: the shared patterns still belong to the two (now
three) vendor paths; only the loading mechanism differs.

## 2. Detection design (POWER.md Step 1)

### 2.1 Source detection

Order is load-bearing because the signals are nested: every WebSphere, WebLogic
and WildFly app is *also* a Java app with `pom.xml` and `src/main/java`. A
plain-Java detector placed first would swallow all three.

```
1a .NET        .sln .csproj .vbproj web.config packages.config appsettings.json
1b WebSphere   ibm-*.xml, was.policy, server.xml(Liberty), com.ibm.websphere.* …
1c WebLogic    weblogic*.xml, plan.xml, weblogic.* oracle.weblogic.* com.bea.* …
1d WildFly     jboss-web.xml, jboss-deployment-structure.xml, jboss-ejb3.xml,
               standalone.xml, domain.xml, jboss-cli, module.xml,
               org.jboss.* org.wildfly.* org.infinispan.* org.jboss.logging,
               org.hibernate.* when paired with JBoss modules
1e plain Java  positive: pom.xml/build.gradle/src/main/java/web.xml + framework
               imports;  negative (MUST be absent): all of 1b + 1c + 1d markers
1f COBOL       *.cbl *.cob *.cpy *.bms *.jcl *.csd, EXEC CICS, EXEC SQL …
```

The single structural change to B's existing chain is the insertion of 1d and the
extension of 1e's negative-signal list to include the WildFly markers. B's
ambiguity rules (1f in the old numbering) and the explicit user override are
retained and renumbered to 1g.

**WildFly's `standalone.xml` / `domain.xml` caveat.** These filenames are
generic enough to appear in unrelated projects, so they are specified as
*corroborating* signals rather than sufficient ones: a match on `standalone.xml`
alone does not confirm WildFly unless a `jboss-*`/`org.jboss.*`/`org.wildfly.*`
signal accompanies it. `server.xml` already has the analogous ambiguity between
Tomcat and WebSphere Liberty in B's existing chain.

### 2.2 Target prompt

A second dimension, prompted only after source is known, and skipped entirely if
the user's opening message already named a target:

| Detected source | Prompt | Options |
|---|---|---|
| .NET | target runtime | (a) .NET 8 (b) .NET 10 (c) Java Spring Boot + SPA |
| WebSphere / WebLogic / WildFly / plain Java / COBOL | front-end scope | React / Vue / backend-only |

Design points:

- **No default for either dimension.** Both prompts state this explicitly, because
  a silently-assumed target produces a confidently wrong report.
- The .NET prompt does **not** explain or compare the three options. A's existing
  wording already establishes this ("the user is already aware of the platform
  choice"); it is preserved and extended to three options.
- The front-end prompt exists to *accept* a choice, never to make one (R12.1).
  `backend-only` is a first-class answer, not a fallback — plenty of programmes
  modernize the back end and leave the UI untouched, and in that case
  `frontend-to-spa.md` is not dispatched at all.
- .NET → option (c) is the only combination where the source is .NET and the
  front-end question also applies, so it chains both prompts.

## 3. Dispatch table design (POWER.md Step 2)

Shape: one row per source + target combination, with an ordered file list. Order
within a row matters — universal framework first, then the source+target leaf,
then shared modules, then conditional dimensions — because later files assume the
vocabulary of earlier ones.

```
Every row begins with:
  report-structure.md · evaluation-framework.md · aws-target-services.md
```

| Source | Target | Then load, in order |
|---|---|---|
| .NET | .NET 8 or .NET 10 | `dotnet-to-aws.md` |
| .NET | Java Spring Boot + SPA | `dotnet-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md` |
| WebSphere | Spring Boot | `websphere-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md`¹ |
| WebLogic | Spring Boot | `weblogic-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md`¹ |
| WildFly / JBoss EAP | Spring Boot | `wildfly-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md`¹ |
| plain Java | Spring Boot 3.x | `java-to-springboot.md`, `frontend-to-spa.md`¹ |
| COBOL | Spring Boot | `cobol-to-java.md`, `frontend-to-spa.md`¹ |

¹ only when the front-end answer is React or Vue; omitted for backend-only.

Plus one orthogonal conditional row, applying to any source:

| Condition | Also load |
|---|---|
| Oracle detected **and** user confirms Oracle → PostgreSQL in scope | `oracle-to-postgresql.md` |

`java-to-springboot.md` deliberately does **not** get
`j2ee-to-springboot-reactive.md`: it is the non-app-server path, and the shared
module is about replacing app-server constructs (EJB, JTA, vendor JNDI) that a
plain Tomcat/Struts app does not have. This preserves B's existing separation.

## 4. Mapping questionnaire depth onto existing report sections

I4 forbids new report sections, so every new criterion must land inside one of
the existing 11. The mapping below is the design contract; each steering file
states which section its findings surface in, so the model has no reason to
invent a section.

| Criterion cluster | Surfaces in |
|---|---|
| Runtime/vendor version, build tooling, buildability, LOC, layering, tests, artifact, config/secrets, dead code | 3 Visual Architecture State, 4 Critical Findings Matrix |
| Where business logic lives; architectural seams | 3 (component diagram), 4 |
| Third-party and commercial dependencies with licence and target availability | 5 Proprietary Dependency Analysis |
| Windows lock-in cluster (.NET) | 4 as its own findings cluster, 5 for the commercial libraries within it |
| Proprietary vendor APIs (J2EE) — #1 risk | 5 as a first-class cluster, cross-referenced from 4 |
| Removed-API usage, javax/jakarta position, native code | 4 |
| Auth mechanism and blast radius; session state and caching | 4 |
| Integration inventory and contracts | 3 (integration diagram), 4 |
| SQL Server / Oracle footprint, PL/SQL inventory, scope question | 6 Database Analysis |
| Front-end inventory, SPA sizing, what does not port | 3, 4 |
| Open questions requiring customer input (R6) | 4 as explicitly-flagged open items, and 2 Executive Summary as caveats on confidence |

**Gating findings.** R5.1 needs a non-building baseline to outrank ordinary
findings. Rather than add a section, it is expressed as a *priority* within
section 4's existing matrix — the highest priority band, with the explicit
consequence that downstream claims are unvalidated until the baseline builds.
This reuses the existing structure exactly as I4 requires.

## 5. Honesty rule design (R6)

The rule is expressed as a two-column contract in `evaluation-framework.md`
mirroring the workbooks' own `Draft answer source` column, which is the cleanest
available precedent:

- **Derivable from source** → the analyzer must determine it and must not ask.
- **Requires customer input** → the analyzer must name it as an open question,
  must not guess, and must not silently omit it.

The `Code analysis` rows of the .NET workbook are adopted as the **floor** for
the first column — if the workbook says code analysis can answer it, the analyzer
is expected to answer it. This gives the rule an external, verifiable benchmark
rather than a subjective one.

Framing follows I5: open questions are presented as inputs a modernization
specialist will gather, not as analyzer failures.

## 6. New steering file designs

All three new files adopt the section skeleton already shared by
`websphere-to-springboot.md` and `weblogic-to-springboot.md`, so that a reader
moving between paths finds the same shape:

```
front matter (inclusion: manual)
# Title
## Objective
## Platform Detection
## Migration Strategy Bank
## Code Transformation Examples   (before → after pairs)
## Platform-Specific Risks
## Validation Checklist
```

### 6.1 `wildfly-to-springboot.md`

Mirrors the WebSphere/WebLogic skeleton exactly. Strategy bank covers: JBoss
Modules classloading → Maven/Gradle flat classpath; `standalone.xml` subsystems →
`application.yml`; Undertow → embedded Tomcat/Netty; Infinispan → Spring Cache +
ElastiCache; HornetQ / ActiveMQ Artemis → Amazon MQ/SQS/MSK; JBoss Remoting →
REST/gRPC; Elytron, PicketLink and legacy security domains → Spring Security;
Narayana → Spring `@Transactional` / R2DBC; `datasources` subsystem JNDI → Spring
DataSource; CLI-driven deployment → container image; EAP subscription cost as a
business driver.

**Distinguishing design point:** the file must state WildFly's *advantage*.
Hibernate and Jakarta EE alignment is frequently already closer to Spring Boot 3
than WebSphere or WebLogic, so the effort profile genuinely differs. Copying the
WebSphere risk posture wholesale would misrepresent it — this is the substantive
reason the three vendor files stay separate rather than collapsing into one.

### 6.2 `frontend-to-spa.md`

Departs from the vendor skeleton because it is a *dimension*, not a platform. Its
spine is the sizing decision:

```
## Objective
## Current Front-End Detection        → screen inventory
## The Dominant Sizing Question: does a REST API already exist?
## Full SPA vs Hybrid                 → consequences of each, customer chooses
## Business Logic in the View Layer   → quantified
## Session and Auth Interaction
## What Does Not Port Cleanly         → its own risk class
## Target-Side Patterns
## COBOL BMS / 3270 Mapping
## Validation Checklist
```

The REST-API question is placed *before* the full-vs-hybrid discussion because it
determines whether that discussion is even meaningful: with no API, both options
carry a business-logic extraction workstream, and presenting them as
front-end-only choices would understate both (R12.2).

Screen inventory is defined as counts of pages, forms, custom tag libraries,
server-side includes, master pages and templates. Per I3 these are *inventory*,
never converted into an effort figure.

### 6.3 `oracle-to-postgresql.md`

Structured as inventory → constructs → proprietary features → types → data
access → sizing, so it reads in the order a migration is actually planned.

The empty-string-is-NULL difference gets its own callout under a **silent
behaviour change** heading, separated from the syntax table. Oracle treats `''`
as NULL; PostgreSQL treats it as a zero-length string. Nothing fails to compile
and no error is raised — `WHERE col IS NULL` simply stops matching rows it used
to match. Grouping it with `DECODE` → `CASE` would bury a correctness risk among
mechanical rewrites.

## 7. Defect fix designs

### 7.1 Duplicated decision tree (`dotnet-to-aws.md`)

The two blocks carry byte-identical Mermaid and divergent prose. Resolution: one
section, one diagram, the first copy's richer
`Decision Node | What We Scanned | What We Found | Result` table and its ✅/❌
path-highlighting guidance retained. The second block's prose is read in full
first and any unique guidance folded into the surviving section before deletion,
so the fix is a merge rather than a truncation.

### 7.2 Self-contradicting ASCII diagram (`evaluation-framework.md`)

The box-drawing diagram is converted to a Mermaid `flowchart` preserving the
exact semantics: modernized application (ECS/EKS) containing an API
wrapper/client, connected by REST/gRPC to an EC2 legacy component host
containing an API wrapper service which fronts the legacy component. A colour
legend is added per I3, which the ASCII version could not carry. This matters
beyond tidiness: a steering file that forbids ASCII art on one line and
demonstrates it 36 lines later teaches the model the opposite of the rule.

## 8. Sequencing rationale

| Phase | Why here |
|---|---|
| 0 Safety | Hooks must be off before the first edit, or they fire ~13 times and overwrite the README deliberately edited in Phase 1. |
| 1 Merge | Establishes the 7-row structure and dispatch contract that Phases 2–5 write into. The `dotnet-to-springboot.md` import is committed alone so a 41 KB file with no git ancestry enters history as a clean single-file addition. |
| 2 .NET depth | Touches only files that exist after Phase 1. |
| 3 WildFly | New path; needs the Phase 1 dispatch table to plug into. |
| 4 Front-end | Cross-cuts six of the seven rows, so it lands after all of them exist. |
| 5 Oracle | Orthogonal conditional; last of the content phases. |
| 6 Cleanup | Defect fixes, version bump, verification, notes, hook restore. Verification must run after all content exists. |

## 9. Risks in executing this plan

| Risk | Handling |
|---|---|
| Hooks re-fire mid-task and clobber the README | Disabled in Phase 0; restoring them is an explicit Phase 6 task; the toggle is untracked so it cannot be verified by `git status` — it is checked by reading the files back. |
| Spec docs mistaken for committed work | Stated at the top of each spec document. |
| New content drifting into forbidden territory (dollar amounts, day estimates, go/no-go tables) | Each new file is checked against I3 and I5 after writing, by grep for currency symbols, `days`/`hours`, and decision-table phrasing. |
| Report section creep | Phase 6 verification counts the numbered sections in `report-structure.md` and confirms 11. |
| A's `#[[file:]]` deltas reintroducing a forbidden mechanism | Adapted at apply time (§1.2); Phase 6 greps for `#[[file:` and `fileMatch` across the repo. |
