# Migration Notes — Mirroring v3.0.0 into the atx Monolith

## Purpose and scope

This repository is the canonical source of the Legacy App Modernization Analyzer Kiro Power. A second,
independently-structured copy of the same knowledge exists as a single flattened document:

```
Code/atx-app-mod-analyzer/atx-txfrm-defn/transformation_definition.md
```

This file records **what changed in v3.0.0 and what therefore needs mirroring into that monolith**,
section by section. It is a hand-off document for whoever updates the monolith. It is not a script,
and it is deliberately not automated.

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

Nothing below has been applied to it.

---

## 1. New reference guides to inline

Four steering files are new or newly-relevant and have no counterpart in the monolith. Each needs
inlining under `# REFERENCE KNOWLEDGE — PLATFORM-SPECIFIC ANALYSIS GUIDES`, following the existing
convention (level-1 heading per guide, body inlined, no front matter).

| Source file in this repo | Lines | Notes for inlining |
|---|---|---|
| `steering/dotnet-to-springboot.md` | 966 | .NET Framework → Java Spring Boot Reactive. **Carries a hard rule that must survive inlining**: never propose a ".NET 8 first, then Java" bridge pathway; all three report pathways must terminate in Java |
| `steering/wildfly-to-springboot.md` | 697 | WildFly / JBoss EAP → Spring Boot. Includes the "starting position is genuinely different" section, which must not be dropped — it is the reason the vendor files stay separate |
| `steering/frontend-to-spa.md` | 480 | Cross-cutting front-end dimension. **Carries a hard rule**: never compare or advocate React vs Vue |
| `steering/oracle-to-postgresql.md` | 338 | Cross-cutting Oracle → PostgreSQL workstream. Conditional on confirmed scope |

Because the monolith has no dispatch mechanism — everything is already in context — the conditional
loading of `frontend-to-spa` and `oracle-to-postgresql` must be re-expressed as **applicability
conditions in prose** at the top of each inlined guide:

- Front-end guide: *"Apply this section only when the user has named React or Vue as the front-end target. If the answer was backend-only, skip it entirely."*
- Oracle guide: *"Apply this section only when Oracle is detected and the user has confirmed Oracle → PostgreSQL is in scope."*

## 2. Updated reference guides to re-inline

These inlined guides have changed materially and need refreshing from this repository:

| Guide | Change summary |
|---|---|
| `dotnet-to-aws.md` | +268 lines net. Analyzer Mission section; .NET 10 as a selectable target; upgrade-path modelling; Windows containers interim hop; database scope fix; exact version detection; .NET questionnaire depth; **duplicated decision-tree section merged** (see §6) |
| `evaluation-framework.md` | +234 lines net. Mandatory Baseline Inventory B1–B16; Gating Findings; derivable-vs-customer-input contract; **ASCII diagram converted to Mermaid** (see §6) |
| `j2ee-to-springboot.md` | +90 lines. New "Required J2EE / Java Analysis Depth" section, mandatory for WebSphere, WebLogic and WildFly |
| `java-to-springboot.md` | +92 lines. New "Required Java Analysis Depth" section |
| `websphere-to-springboot.md` | +21 lines. Proprietary APIs reframed as the #1 J2EE risk, with WebSphere-specific rows |
| `weblogic-to-springboot.md` | +51 lines. Same reframing, plus Oracle database options made scope-aware |
| `cobol-to-java.md` | +154 lines. BMS cross-reference; "Required Mainframe Analysis Depth" M1–M6 |
| `aws-target-services.md` | +64 lines. WildFly/JBoss rows; app-server licensing table; database table made scope-aware |

## 3. `SUPPORTED MODERNIZATION PATHS` — replace the 5-row table

The monolith's table needs to become 7 rows across 6 source families, plus the two cross-cutting
dimensions. Mirror from `POWER.md`:

| # | Source | Target | Reference |
|---|---|---|---|
| 1 | .NET Framework | .NET 8 **or .NET 10** + AWS | "dotnet-to-aws" |
| 2 | .NET Framework | Java Spring Boot + React/Vue + AWS | "dotnet-to-springboot" |
| 3 | J2EE — IBM WebSphere | Spring Boot + React/Vue + AWS | "websphere-to-springboot" |
| 4 | J2EE — Oracle WebLogic | Spring Boot + React/Vue + AWS | "weblogic-to-springboot" |
| 5 | J2EE — Red Hat WildFly / JBoss EAP | Spring Boot + React/Vue + AWS | "wildfly-to-springboot" |
| 6 | Java SE 8 / plain Java | Spring Boot 3.x + Java 17/21 + React/Vue + AWS | "java-to-springboot" |
| 7 | COBOL / Mainframe | Java Spring Boot + React/Vue + AWS | "cobol-to-java" |

Plus, as conditional dimensions rather than paths: "frontend-to-spa" and "oracle-to-postgresql".

## 4. `WORKFLOW` → Step 1 — the biggest structural change

The monolith's Step 1 is **single-dimension**: it detects the source and proceeds. v3.0.0 makes
detection **two-dimensional**, and this is the change most likely to be missed because it alters the
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

- **.NET source** → ask: (a) .NET 8, (b) .NET 10, (c) Java Spring Boot + SPA. Do not compare or explain the options; the user already knows the choice
- **Any Java / J2EE / COBOL source, and .NET option (c)** → ask the front-end scope: React, Vue, or backend-only

Rules that must carry over verbatim in intent:
- **No default is assumed for either dimension**
- **If the user's opening message already stated a target, skip the prompt**
- The front-end framework is **user input, never an analyzer recommendation**
- **backend-only is a first-class answer**, not a fallback — the front-end guidance is then skipped entirely

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
| .NET | .NET 8 or .NET 10 | dotnet-to-aws |
| .NET | Java Spring Boot + SPA | dotnet-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WebSphere | Spring Boot | websphere-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WebLogic | Spring Boot | weblogic-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| WildFly / JBoss EAP | Spring Boot | wildfly-to-springboot, j2ee-to-springboot, frontend-to-spa¹ |
| plain Java | Spring Boot 3.x | java-to-springboot, frontend-to-spa¹ |
| COBOL | Java Spring Boot | cobol-to-java, frontend-to-spa¹ |

¹ only when the front-end answer was React or Vue.

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
- Made the diagram runtime-neutral, since .NET 10 is now selectable: `Target OS Supported by Modern .NET?` and `Move to Modern .NET — .NET 8 or .NET 10 per Step 1B`

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

## 7. Report-section mapping — where the new depth lands

**No new report sections were added in v3.0.0.** All new analysis depth surfaces inside existing
sections. When mirroring, map onto the monolith's **13-section** numbering, not this repository's 11:

| New content | This repo's section | Monolith section (COBOL / non-COBOL) |
|---|---|---|
| Baseline inventory findings, layering, tests, artifact, config | 3 Visual Architecture State | 3 |
| Gating findings (highest priority band); Windows lock-in cluster; proprietary vendor API cluster; removed APIs; auth and session; open questions | 4 Critical Findings Matrix | **4** — note the monolith's section 4 also carries the Decision Tree Findings Map |
| Third-party and commercial dependencies with licence and target availability | 5 Proprietary Dependency Analysis | **7** (5 for non-COBOL) |
| SQL Server / Oracle footprint, PL/SQL inventory, scope question | 6 Database Analysis | **8** (6 for non-COBOL) |
| Front-end inventory, SPA sizing, what does not port cleanly | 3 and 4 | 3 and 4 |
| Confidence caveats from gating findings and open questions | 2 Executive Summary | 2 |

The COBOL-specific mainframe depth (M1–M6) interacts with the monolith's promoted sections: **M3
(DB2 vs VSAM split)** belongs with section 5 Data Inventory, and **M2 (CICS coupling depth)** belongs
with section 6 Business Logic Extraction Summary. This is precisely the mapping a regeneration would
destroy.

## 8. Metadata

- Version → `3.0.0`
- Description and keywords → add WildFly, JBoss, React, Vue, SPA, PostgreSQL, Oracle, .NET 10 (see `POWER.md` front matter for the exact strings)

## 9. Invariants that must survive mirroring

Verify each of these against the monolith after any update:

1. Report output filename stays `yymmddhhmm_MODERNIZATION_REPORT.md` (UTC)
2. Exactly **3** ranked pathways per report
3. No ASCII art — all diagrams Mermaid, every architecture diagram with a colour legend
4. No dollar amounts and no hour/day effort estimates in the default report; file, line and screen counts are **inventory**, never effort proxies
5. The monolith keeps its **13**-section structure with the COBOL promotions and dual numbering intact
6. Analyzer ground rules hold: findings framed as evidence for modernization specialists; **no go/no-go decision tables**; no failure case studies; always direct readers to AWS Modernization Specialists or authorized AWS Modernization Partners
7. When the user has chosen Java, **never** propose a ".NET 8 first, then Java" bridge pathway
8. **Never** compare or advocate React vs Vue
9. Database migration scope is **never assumed** in either direction — report the footprint, ask the question
10. Open questions that cannot be derived from source are **named, not guessed**

## 10. Suggested order of work

1. Apply the two defect fixes (§6) to the monolith's existing inlined content
2. Refresh the eight updated guides (§2)
3. Inline the four new guides (§1), adding their applicability conditions in prose
4. Replace the paths table (§3)
5. Rewrite Step 1 as two-dimensional detection (§4) — the highest-risk change, do it deliberately
6. Re-express Step 2 as applicability guidance (§5)
7. Update metadata (§8)
8. Walk the invariant checklist (§9)
9. Publish only as a separate, explicit decision — `atx custom def publish` is **not** part of this work
