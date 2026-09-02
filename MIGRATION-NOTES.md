# Migration Notes — Mirroring v4.0.0 into the atx Monolith

## Purpose and scope

This repository is the canonical source of the Legacy App Modernization Analyzer Kiro Power. A second,
independently-structured copy of the same knowledge exists as a single flattened document:

```
Code/atx-app-mod-analyzer/atx-txfrm-defn/transformation_definition.md
```

This file records **what needs mirroring into that monolith**, section by section. It is a hand-off
document for whoever updates the monolith. It is not a script, and it is deliberately not automated.

**This document now describes the cumulative v3.0.0 + v4.0.0 delta.** The v3.0.0 mirroring was never
applied — the monolith is still at its pre-merge state (see *Monolith baseline as inspected*). Rather
than mirroring v3.0.0 and then re-mirroring v4.0.0's target changes on top of it, apply the **v4.0.0
end state directly**. Every table and prompt below has already been re-grounded on the v4.0.0 targets,
so following this document once lands the monolith on the current canonical content.

Sections §1–§10 carry the structural v3.0.0 changes with v4.0.0 targets folded in. §11 carries the
v4.0.0 content changes that have no v3.0.0 counterpart and would otherwise be missed.

## ⛔ Do NOT regenerate the monolith from this repository

**The monolith is not a mechanical inline of these steering files.** It uses a **different report
structure**, and regenerating it from `POWER.md` + `steering/*.md` would silently revert a deliberate
restructuring.

| | This repository (`steering/report-structure.md`) | The atx monolith |
|---|---|---|
| Numbered report sections | **11** | **13** |
| Decision Tree Findings Map | Presented within existing sections | **Folded into section 4**, whose heading is "Decision Tree Findings Map (for .NET / Java / COBOL) / Critical Findings Matrix" |
| COBOL Data Inventory | Inside the COBOL steering guidance | **Promoted to section 5**, marked COBOL/Mainframe ONLY |
| COBOL Business Logic Extraction Summary | Inside the COBOL steering guidance | **Promoted to section 6**, marked COBOL/Mainframe ONLY |
| Sections 7–13 | n/a | Carry dual numbering, e.g. "Section 7: Proprietary Dependency Analysis (Section 5 for non-COBOL)" |
| Steering files | 13 separate files, `inclusion: manual`, dispatched from POWER.md Step 2 | Inlined as "REFERENCE KNOWLEDGE — PLATFORM-SPECIFIC ANALYSIS GUIDES" already in context |

That dual-numbering scheme — where a COBOL report has 13 sections and a non-COBOL report has 11 — is
the point of the restructuring. A regeneration would flatten it back to 11 for every platform and lose
the COBOL promotion.

**Also do not run `atx custom def publish`.** Publishing is a separate, deliberate decision.

## Monolith baseline as inspected

At the time of writing, the monolith is at the **pre-merge** state. Verified by inspection:

- 4,731 lines, 13 report sections
- 5 modernization paths: .NET → .NET 8, WebSphere, WebLogic, plain Java, COBOL
- Inlines: evaluation framework, AWS target services, `dotnet-to-aws`, `websphere-to-springboot`, `weblogic-to-springboot`, `j2ee-to-springboot`, `java-to-springboot`, `cobol-to-java`
- No occurrences of: WildFly, `dotnet-to-springboot`, `.NET 10`, front-end/SPA content, Oracle → PostgreSQL content, PL/SQL conversion content
- Platform detection is single-dimension (source only); there is no target-platform prompt
- `SUPPORTED MODERNIZATION PATHS` table has 5 rows

Nothing below has been applied to it. Note that the monolith's `.NET → .NET 8` path and any
`Spring Boot 3` / `Java 17` target text is now **doubly stale**: .NET 8 support ends 10 November 2026
and all Spring Boot 3.x lines went out of OSS support on 30 June 2026.

---

## 1. New reference guides to inline

Four steering files are new or newly-relevant and have no counterpart in the monolith. Each needs
inlining under `# REFERENCE KNOWLEDGE — PLATFORM-SPECIFIC ANALYSIS GUIDES`, following the existing
convention (level-1 heading per guide, body inlined, no front matter).

| Source file in this repo | Lines | Notes for inlining |
|---|---|---|
| `steering/dotnet-to-springboot.md` | 994 | .NET Framework → Java Spring Boot. **Carries two hard rules that must survive inlining**: never propose a ".NET first, then Java" bridge pathway — all three report pathways must terminate in Java; and AWS Transform for .NET does **not** serve C# → Java, so it must not be offered as automation on this path |
| `steering/wildfly-to-springboot.md` | 727 | WildFly / JBoss EAP → Spring Boot. Includes the "starting position is genuinely different" section, which must not be dropped — it is the reason the vendor files stay separate. **Also carries the Undertow hard blocker** (§11) |
| `steering/frontend-to-spa.md` | 581 | Cross-cutting front-end dimension. **Carries a hard rule**: the framework is user input, never an analyzer recommendation, and no framework is compared against or advocated over another |
| `steering/oracle-to-postgresql.md` | 338 | Cross-cutting Oracle → PostgreSQL workstream. Conditional on confirmed scope |

Because the monolith has no dispatch mechanism — everything is already in context — the conditional
loading of `frontend-to-spa` and `oracle-to-postgresql` must be re-expressed as **applicability
conditions in prose** at the top of each inlined guide:

- Front-end guide: *"Apply this section only when the user has named a front-end framework — React, Angular, Vue, Svelte or another — or said the choice is not yet decided. If the answer was backend-only, skip it entirely."*
- Oracle guide: *"Apply this section only when Oracle is detected and the user has confirmed Oracle → PostgreSQL is in scope."*

Note the filename: the shared J2EE module is `steering/j2ee-to-springboot.md`. It was previously
`j2ee-to-springboot-reactive.md`; "Reactive" was dropped from that filename and from four steering
file titles in v4.0.0 (§11).

## 2. Updated reference guides to re-inline

These inlined guides have changed materially and need refreshing from this repository:

| Guide | Change summary |
|---|---|
| `dotnet-to-aws.md` | Analyzer Mission section; **.NET 10 as the sole target and .NET 8 retired** (§11); upgrade-path modelling; AWS Transform coverage matrix; Windows containers interim hop; database scope fix; exact version detection; .NET questionnaire depth; **duplicated decision-tree section merged** (see §6) |
| `evaluation-framework.md` | Mandatory Baseline Inventory B1–B16; Gating Findings; derivable-vs-customer-input contract; **ASCII diagram converted to Mermaid** (see §6) |
| `j2ee-to-springboot.md` | "Required J2EE / Java Analysis Depth" section, mandatory for WebSphere, WebLogic and WildFly; **the canonical "Blocking or Reactive: a Decision, Not a Default" section** (§11); Jakarta EE 11 baseline correction |
| `java-to-springboot.md` | "Required Java Analysis Depth" section; **three-stage upgrade sequence, Boot 4 breaking-change cluster, three-position namespace model, Tomcat 11 row, Java 21/25 dependency matrix** (§11) |
| `websphere-to-springboot.md` | Proprietary APIs reframed as the #1 J2EE risk, with WebSphere-specific rows |
| `weblogic-to-springboot.md` | Same reframing, plus Oracle database options made scope-aware |
| `cobol-to-java.md` | BMS cross-reference; "Required Mainframe Analysis Depth" M1–M6; **Spring Batch in-memory default under Boot 4** (§11) |
| `aws-target-services.md` | WildFly/JBoss rows; app-server licensing table; database table made scope-aware; **Java Runtime Targets table and the Undertow blocker row** (§11) |

## 3. `SUPPORTED MODERNIZATION PATHS` — replace the 5-row table

The monolith's table needs to become 7 rows across 6 source families, plus the two cross-cutting
dimensions. Mirror from `POWER.md`:

| # | Source | Target | Reference |
|---|---|---|---|
| 1 | .NET Framework | **.NET 10** (LTS) + AWS | "dotnet-to-aws" |
| 2 | .NET Framework | Spring Boot 4.1.x + Java 21/25 + SPA + AWS | "dotnet-to-springboot" |
| 3 | J2EE — IBM WebSphere | Spring Boot 4.1.x + Java 21/25 + AWS | "websphere-to-springboot" |
| 4 | J2EE — Oracle WebLogic | Spring Boot 4.1.x + Java 21/25 + AWS | "weblogic-to-springboot" |
| 5 | J2EE — Red Hat WildFly / JBoss EAP | Spring Boot 4.1.x + Java 21/25 + AWS | "wildfly-to-springboot" |
| 6 | Java SE 8 / plain Java | Spring Boot 4.1.x + Java 21/25 + AWS | "java-to-springboot" |
| 7 | COBOL / Mainframe | Spring Boot 4.1.x + Java 21/25 + AWS | "cobol-to-java" |

There is **no `.NET → .NET 8` row** and no ".NET 8 or .NET 10" row. The front-end framework is not
named in the target column, because it is whatever the user names.

Plus, as conditional dimensions rather than paths: "frontend-to-spa" and "oracle-to-postgresql".

## 4. `WORKFLOW` → Step 1 — the biggest structural change

The monolith's Step 1 is **single-dimension**: it detects the source and proceeds. Detection must
become **two-dimensional**, and this is the change most likely to be missed because it alters the
control flow rather than adding content.

**4a. Source detection order gains WildFly.** New order, which is load-bearing:

```
.NET → WebSphere → WebLogic → WildFly → plain Java → COBOL
```

WildFly is inserted **before** plain Java. The plain-Java detector must stay last among the Java-family
detectors.

**4b. WildFly detection specifics.** Sufficient signals: `jboss-web.xml`,
`jboss-deployment-structure.xml`, `jboss-ejb3.xml`, `jboss-app.xml`, `jboss-ejb-client.*`,
`module.xml` under a `modules/` tree, `jboss-cli`. Imports: `org.jboss.*`, `org.wildfly.*`,
`org.infinispan.*`, `org.jboss.logging`; and `org.hibernate.*` **only when paired** with JBoss markers.

**Corroborating but NOT sufficient**: `standalone.xml`, `domain.xml`. These filenames occur in
unrelated projects, so they confirm WildFly only alongside a `jboss-*` / `org.jboss.*` /
`org.wildfly.*` signal. Preserve this qualification — dropping it produces false positives.

**4c. Plain-Java negative signals must be extended** with the WildFly markers, alongside the existing
IBM and WebLogic ones.

**4d. A target-platform prompt must be added (new, no counterpart in the monolith).** After source
detection:

- **.NET source** → ask: (a) **.NET 10**, or (b) Java Spring Boot + SPA. **Two options, not three** — there is no .NET 8 option. Do not compare or explain the options; the user already knows the choice
- **Any Java / J2EE / COBOL source, and .NET option (b)** → ask the front-end scope, offering React, Angular, Vue, Svelte, another framework the user names, not-yet-decided, or backend-only

Rules that must carry over verbatim in intent:
- **No default is assumed for either dimension**
- **If the user's opening message already stated a target, skip the prompt**
- The front-end framework is **user input, never an analyzer recommendation**
- **backend-only is a first-class answer**, not a fallback — the front-end guidance is then skipped entirely
- **not-yet-decided is also a first-class answer** — the front-end guidance still applies, sized framework-neutrally
- If the user asks for **.NET 8 specifically**, state the 10 November 2026 support date plainly and confirm before proceeding. Do not silently comply, and do not silently override them either

**4e. Ambiguity rules gain a case**: where markers for two *different* app servers are present, ask
which is authoritative rather than merging two vendor guides in one pass.

## 5. `WORKFLOW` → Step 2 — dispatch becomes applicability

In this repository, Step 2 is an authoritative dispatch table because steering files are
`inclusion: manual` and load explicitly. **The monolith has no such mechanism** — every guide is
already in context — so the dispatch table cannot be mirrored literally.

Re-express it as **applicability guidance**: which inlined guides apply to which detected
source + target combination, and in what order to apply them.

| Source | Target | Apply, in order |
|---|---|---|
| .NET | .NET 10 | dotnet-to-aws |
| .NET | Spring Boot 4.1.x + SPA | dotnet-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WebSphere | Spring Boot 4.1.x | websphere-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WebLogic | Spring Boot 4.1.x | weblogic-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WildFly / JBoss EAP | Spring Boot 4.1.x | wildfly-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| plain Java | Spring Boot 4.1.x | java-to-springboot, frontend-to-spa¹ |
| COBOL | Spring Boot 4.1.x | cobol-to-java, frontend-to-spa¹ |

¹ only when the user named a front-end framework or said the choice is not yet decided; skipped
entirely on backend-only.

Orthogonal: apply **oracle-to-postgresql** for any source where Oracle is detected **and** the customer
confirms the migration is in scope.

Preserve two structural points:
- `java-to-springboot` deliberately does **not** take `j2ee-to-springboot` — the shared module concerns application-server constructs a plain Tomcat/Struts application does not have
- The universal three (report structure, evaluation framework, AWS target services) apply to **every** combination

## 6. Two pre-existing defects fixed here — apply the same fixes

Both defects exist in the monolith too, since it was generated from the pre-fix content.

**6a. Duplicated .NET decision tree.** `dotnet-to-aws` carried the **same 84-line Mermaid
decision-tree block twice**, with different surrounding prose. Merged into one section:

- Kept the single diagram
- Kept the **first** copy's richer `Decision Node | What We Scanned | What We Found | Result` table
- Kept its ✅/❌ path-highlighting guidance
- **Folded in the second copy's unique guidance** rather than discarding it: explain what was detected and why it blocks at **blocker (red) nodes**, explain how cumulative findings led to the target at the **final (green) node**, and state the traceability chain codebase evidence → decision logic → recommended target
- The final node names **.NET 10** as the single modern-.NET destination

Check the monolith for the same duplication before inlining the updated guide.

**6b. Self-contradicting ASCII diagram.** `evaluation-framework` stated "NEVER use ASCII art" and then
drew a 26-line box-drawing diagram under "Recommended Architecture" — teaching the model the opposite
of the rule. Converted to a Mermaid `flowchart` preserving the exact semantics (modernized application
↔ REST/gRPC ↔ EC2 legacy component host containing an API wrapper service fronting the legacy
component), with a colour legend added.

**In the monolith this diagram sits at approximately line 595**, under
`### Recommended Architecture` within the inlined evaluation framework. Replace it there too. The
monolith's own `ABSOLUTE RULES` and `VISUALIZATION REQUIREMENTS SUMMARY` forbid ASCII art, so the
contradiction is if anything sharper there.

Directory and file trees in fenced code blocks using `├──`, `└──` and `│` are **permitted** and are not
what the ASCII-art rule prohibits. Do not strip those.

## 7. Report-section mapping — where the new depth lands

**No new report sections were added in v3.0.0 or v4.0.0.** All new analysis depth surfaces inside
existing sections. When mirroring, map onto the monolith's **13-section** numbering, not this
repository's 11:

| New content | This repo's section | Monolith section (COBOL / non-COBOL) |
|---|---|---|
| Baseline inventory findings, layering, tests, artifact, config | 3 Visual Architecture State | 3 |
| Gating findings (highest priority band); Windows lock-in cluster; proprietary vendor API cluster; removed APIs; auth and session; open questions; **Undertow removal; Spring Security 7 CSRF-by-default** | 4 Critical Findings Matrix | **4** — note the monolith's section 4 also carries the Decision Tree Findings Map |
| Third-party and commercial dependencies with licence and target availability; **target-JDK (21/25) and Jakarta EE 11 readiness** | 5 Proprietary Dependency Analysis | **7** (5 for non-COBOL) |
| SQL Server / Oracle footprint, PL/SQL inventory, scope question | 6 Database Analysis | **8** (6 for non-COBOL) |
| Front-end inventory, SPA sizing, what does not port cleanly | 3 and 4 | 3 and 4 |
| Confidence caveats from gating findings and open questions | 2 Executive Summary | 2 |

The COBOL-specific mainframe depth (M1–M6) interacts with the monolith's promoted sections: **M3
(DB2 vs VSAM split)** belongs with section 5 Data Inventory, and **M2 (CICS coupling depth)** belongs
with section 6 Business Logic Extraction Summary. This is precisely the mapping a regeneration would
destroy.

## 8. Metadata

- Version → `4.0.0`
- Description and keywords → see `POWER.md` front matter for the exact strings. Remove `.NET 8`; add `.NET 10`, WildFly, JBoss, Angular, Svelte, SPA, Spring Boot 4 / 4.1, Spring Framework 7, Java 21, Java 25, virtual threads, Jakarta EE 11, PostgreSQL, Oracle

## 9. Invariants that must survive mirroring

Verify each of these against the monolith after any update:

1. Report output filename stays `yymmddhhmm_MODERNIZATION_REPORT.md` (UTC)
2. Exactly **3** ranked pathways per report
3. No ASCII art — all diagrams Mermaid, every architecture diagram with a colour legend. Directory/file trees in code blocks are exempt
4. No dollar amounts and no hour/day effort estimates in the default report; file, line and screen counts are **inventory**, never effort proxies
5. The monolith keeps its **13**-section structure with the COBOL promotions and dual numbering intact
6. Analyzer ground rules hold: findings framed as evidence for modernization specialists; **no go/no-go decision tables**; no failure case studies; always direct readers to AWS Modernization Specialists or authorized AWS Modernization Partners
7. When the user has chosen Java, **never** propose a ".NET first, then Java" bridge pathway
8. **Never** compare or advocate one front-end framework over another; the framework is always user input
9. Database migration scope is **never assumed** in either direction — report the footprint, ask the question
10. Open questions that cannot be derived from source are **named, not guessed**
11. **.NET 8 is never offered as a target.** It appears only as a detected current state, a tooling trap in AWS Transform, or a dependency ceiling
12. **Blocking and reactive are presented without ranking.** Blocking-plus-virtual-threads is the stated starting assumption, not a recommendation, and reactive is never described as the default modern choice

## 10. Suggested order of work

1. Apply the two defect fixes (§6) to the monolith's existing inlined content
2. Refresh the eight updated guides (§2)
3. Inline the four new guides (§1), adding their applicability conditions in prose
4. Replace the paths table (§3)
5. Rewrite Step 1 as two-dimensional detection (§4) — the highest-risk change, do it deliberately
6. Re-express Step 2 as applicability guidance (§5)
7. Sweep the whole monolith for the v4.0.0 target changes (§11) — this is a global find-and-verify pass, not a per-guide one
8. Update metadata (§8)
9. Walk the invariant checklist (§9)
10. Publish only as a separate, explicit decision — `atx custom def publish` is **not** part of this work

---

## 11. v4.0.0 target changes — a global sweep, not a per-guide edit

These changes cut across every inlined guide and across the monolith's own workflow and rules text.
Treat this as a search-and-verify pass over the whole document. All facts below were verified on
2 September 2026; sources are recorded in `.kiro/specs/v4-target-refresh/requirements.md`.

### 11a. .NET 8 retired as a target

- .NET 8 and .NET 9 both reach end of support **10 November 2026**. .NET 10 is LTS, supported to
  approximately **November 2028**; the next LTS is .NET 12 (approximately November 2027)
- Remove every ".NET 8" **target** occurrence. Retain .NET 8 only in three roles: a **detected current
  state** (partially modernized, still carrying its own upgrade), a **tooling trap** (AWS Transform for
  .NET offers both 8 and 10 as targets — instruct the team to select 10), and a **dependency ceiling**
  where a commercial library's newest build stops at .NET 8
- Do **not** add a `.NET 8/9 → .NET 10` source family. That is a version bump, not a modernization
  path; report it in the findings matrix with the November 2026 deadline attached
- Do **not** model a `4.x → 8 → 10` two-step. AWS Transform documents .NET Framework 3.5+ as a source
  and .NET 10 as a target, so the direct hop is supported and an intermediate stage buys nothing but an
  extra validation and regression cycle
- The `3.x` pre-step is **verify, don't assume**: AWS Transform lists 3.5+ as a supported source, while
  customer workbooks commonly assume a 3 → 4 hop. State both; .NET 3.0 sits below the documented floor
- Upgrade paths as modelled: `4 → 10`, `3.5 → 10` (verify), `3 → 4 → 10`, `8 → 10`
- AWS Transform for .NET project-type coverage must be stated, not assumed: **C# only** — class
  libraries, console, ASP.NET MVC with Razor views, SPA back ends, Web API, Web Forms, unit tests, WCF.
  **Preview**: WinForms, WPF, Xamarin, VB.NET. **Not transformed**: Blazor UI components, Win32 DLLs
  without core-compatible libraries, repositories without solutions. Porting Assistant for .NET closed
  to new customers on 7 November 2025
- On the .NET → Java path, state plainly that **AWS Transform for .NET does not serve C# → Java**. Its
  targets are .NET 8 and .NET 10, so it cannot be offered as automation for a Java destination

### 11b. Spring targets move to Spring Boot 4.1.x on Java 21/25

- All Spring Boot 3.x lines left OSS support on **30 June 2026**. Boot 4.0 GA'd 20 November 2025 and
  goes end-of-support **31 December 2026**. **Boot 4.1** GA'd 10 June 2026 on Spring Framework 7.0.8,
  patch 4.1.1 on 20 August 2026, supported to 31 July 2027
- Pin **4.1.x**, not "Boot 4", and state the **~13-month minor cadence** so programmes plan for 4.2/4.3
  rather than treating 4.1 as a stable endpoint
- Spring Framework 7: **JDK 17 floor, JDK 25 recommended**, Jakarta EE 11, Kotlin 2.2, GraalVM 25.
  Jakarta EE 11 means Servlet 6.1, JPA 3.2, Bean Validation 3.1
- Target JDK: **Java 21 or 25**, default 25, 21 as the conservative choice, 17 named as the floor only.
  Amazon Corretto 25 GA'd September 2025; Lambda added Java 25 in November 2025. Replace `Corretto 17`
  and `Corretto 17/21` runtime targets with `Corretto 21 or 25`
- "Java 17 clean" is **necessary but not sufficient** for a dependency — confirm it runs on the JDK the
  programme actually targets
- Java sources upgrade in **three stages**, and stage 2 is **mandatory**: Java 8 → 21/25, Boot 2.7 →
  3.5, then 3.5 → 4.1. Boot 3.5 is a **transit version**, never a destination

### 11c. Boot 4 breaking changes to carry into the analysis

- **Undertow is removed** — there is no Servlet 6.1 release of it and there is no configuration
  workaround. This is a **hard blocker on the WildFly / JBoss EAP path**: the estate must land on
  Tomcat 11 or Jetty 12.1. Carry it as a gating finding, not a footnote
- **All Boot 3 deprecations are removed** in Boot 4
- **Spring Security 7**: lambda DSL only, and **CSRF protection is on for API endpoints by default** —
  this surfaces as unexplained 403s. High-priority finding
- **Starter modularisation**: autoconfigure drops from 1,470 to 258 classes; new
  `spring-boot-starter-webmvc`, `-restclient`, `-webclient`, `-kafka` and `-test` companions;
  `*Properties` classes move packages, including `SecurityProperties` constants moving to
  `SecurityFilterProperties`
- **Jackson 3 is the default**: `tools.jackson` packages, unchecked exceptions, `@JsonComponent` →
  `@JacksonComponent`
- **Testing**: `@MockBean` / `@SpyBean` removed in favour of `@MockitoBean` / `@MockitoSpyBean`, and
  `@SpringBootTest` no longer auto-configures MockMvc or TestRestTemplate
- **Spring Batch defaults to in-memory** — a JDBC job repository needs
  `spring-boot-starter-batch-jdbc`. This matters most on the COBOL path, where batch is the bulk of the
  estate
- Boot 4.1 manages **Hibernate 7.4** and **Spring Data JPA 4**; Hibernate 5.x's `javax.persistence` is
  therefore two version steps away, not one
- **Virtual threads remain opt-in**: `spring.threads.virtual.enabled=true`
- OpenRewrite recipe for the major step: `org.openrewrite.java.spring.boot3.UpgradeSpringBoot_4_0`
- R2DBC is still supported

### 11d. The namespace question has three positions, not two

The old binary — `javax` bad, `jakarta` good — is no longer sufficient. Report which of three positions
the codebase occupies:

| Position | Meaning | Distance to a Boot 4.1 target |
|---|---|---|
| `javax.*` (Jakarta EE 8 and earlier) | The rename has not happened | Namespace migration **and** an EE 11 version step |
| `jakarta.*` at EE 9/10 | The rename has happened | An EE 11 version step remains |
| `jakarta.*` at EE 11 | Current | Aligned with the target |

Tomcat compatibility, which is source-side evidence and must **not** be rewritten to the new target:
8.5.x/9.x carry `javax.servlet` and cap at Boot 2.x; 10.0.x/10.1.x carry `jakarta.servlet` and cap at
Boot 3.x; **11.x** carries Servlet 6.1 and is what Boot 4.x needs.

### 11e. Blocking vs reactive is presented as a decision, not a default

- `steering/j2ee-to-springboot-reactive.md` was renamed to `steering/j2ee-to-springboot.md`, and
  "Reactive" was dropped from **five** steering file titles
- The canonical treatment lives in `j2ee-to-springboot.md` as **"Blocking or Reactive: a Decision, Not
  a Default"**, with an equivalent section in `java-to-springboot.md`. Both models are described with
  their real trade-offs and **neither is ranked**
- The analyzer states **blocking plus virtual threads** as its *starting assumption* and asks. It does
  not present reactive as the modern default, and it does not steer a programme into a paradigm shift
  it did not choose. Supporting evidence: virtual threads on Netty won roughly 50% of published
  head-to-heads against WebFlux's roughly 26%
- Virtual-thread **pinning** and `ThreadLocal` behaviour are findings in their own right
- Sweep the monolith for reactive-as-requirement phrasing — 28 such phrases were made model-agnostic
  across five files here — and for any WebFlux-by-default assumption in pathway text

### 11f. The front-end target is any named framework

- Generalised from a hardcoded React-or-Vue choice. Offer React, Angular, Vue, Svelte, another
  framework the user names, not-yet-decided, or backend-only
- The previous hardcoding excluded **Angular despite its higher professional usage than Vue**:
  React 46.9%, Angular 19.8%, Vue 18.4%, Svelte 6.9%
- No comparative superiority claim between front-end frameworks is encoded, in either direction. The
  framework is user input
- Three target-specific considerations were added and should be mirrored: **hybrid embedding** into
  existing server-rendered pages (Vue has a documented edge here), **meta-framework coupling**
  (roughly 78% of new React applications use Next.js, which is a platform decision, not just a library
  one), and **component-library continuity**
