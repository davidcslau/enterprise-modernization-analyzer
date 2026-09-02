# Tasks — v4.0.0 Target Refresh

Requirement IDs refer to `requirements.md`; section refs to `design.md`.

---

## Phase 1 — Targets and prompts

- [x] **1.1** `POWER.md` Step 1B: .NET prompt collapses to a single target, **.NET 10 (LTS)**. Remove the .NET 8 option. _(R1.1)_
- [x] **1.2** `POWER.md` Step 1B: front-end prompt generalised to React / Vue / Angular / Svelte / other (name it) / **undecided** / backend-only. _(R4.1, R4.3)_
- [x] **1.3** `POWER.md` Step 1B: Java target stated as Spring Boot **4.1.x** + Java **21 or 25** (17 floor). _(R2.1, R2.3)_
- [x] **1.4** `POWER.md` Supported Modernization Paths table: targets updated across all 7 rows. _(R1.1, R2.1)_
- [x] **1.5** `POWER.md` cross-cutting dimensions table: front-end row reworded for any named framework. _(R4.1)_
- [x] **1.6** `POWER.md` trigger phrases: add Angular/Svelte/.NET 10/Boot 4 phrases; retire ".NET 8" phrasing. _(R1.1, R4.1)_
- [x] **1.7** `README.md` paths table, cross-cutting table, features list and detection section updated to match. _(R1.1, R2.1, R4.1)_
- [x] **1.8** State the ~13-month Boot minor cadence and .NET 10's support window wherever a target is named. _(R2.2)_

**Commit.** → **CHECKPOINT 1 — stop for review.** _(Q7)_

---

## Phase 2 — .NET depth

`steering/dotnet-to-aws.md`:

- [x] **2.1** **Delete** the .NET 8 vs .NET 10 trade-off table; replace with a single-target section. _(R1.4, design §2)_
- [x] **2.2** State .NET 10's support window (~Nov 2028) and the next LTS (.NET 12, ~Nov 2027) for programme-tail reasoning. _(R1.1)_
- [x] **2.3** Add the AWS Transform supported source/target matrix, including the explicit **"do not select .NET 8 in the tool"** instruction with the 10 Nov 2026 reason. _(R1.5)_
- [x] **2.4** Soften the 3.x → 4.x pre-step to verify-don't-assume, citing AWS Transform's 3.5+ source support and noting 3.0 is below the floor. Keep both positions visible. _(R1.6, design §2)_
- [x] **2.5** Re-ground VB.NET friction on the documented **preview** status; add WinForms/WPF/Xamarin as preview; add Blazor UI components as not transformed. _(R1.7)_
- [x] **2.6** Rework the upgrade-path model: direct `4.x → 10`, and `3.x → 10` subject to 2.4. No `4.x → 8 → 10` two-step. _(R1.3)_
- [x] **2.7** Detected .NET 8/9 as a findings-matrix item requiring its own upgrade before Nov 2026 — not a new source family. _(R1.2)_
- [x] **2.8** Mirror the relevant parts into `steering/dotnet-to-springboot.md` (Java target, so no .NET 10 runtime content, but the AWS Transform and VB.NET facts still apply).

**Commit.**

---

## Phase 3 — Java / J2EE depth for Spring Boot 4.1

- [x] **3.1** `j2ee-to-springboot-reactive.md`: target becomes Boot 4.1.x + Java 21/25 + Jakarta EE 11. _(R2.1, R2.3, R2.4)_
- [x] **3.2** Add the **Tomcat 11 / Servlet 6.1 / Boot 4** row to the namespace-compatibility table in `java-to-springboot.md`; add the three-position namespace model (javax, jakarta EE 9/10, jakarta EE 11). _(R2.5, design §3)_
- [x] **3.3** Replace the two-step sequencing with the **three-stage** sequence, marking Boot 3.5 a mandatory *transit* version and explaining deprecation-as-error. _(R2.6, design §3)_
- [x] **3.4** Add the Boot 4 breaking-change cluster: starter modularisation + `*Properties` package moves, Jackson 3, Spring Security 7 (lambda DSL, CSRF default), test-annotation removals, Spring Batch in-memory, Hibernate 7.4 / Spring Data JPA 4 lazy-loading. _(R2.7)_
- [x] **3.5** `wildfly-to-springboot.md`: promote **Undertow removal to a named hard blocker** with no workaround. _(R2.8)_
- [x] **3.6** `wildfly-to-springboot.md`: correct the "already positioned" advantage — WildFly 27+/EAP 8 are Jakarta EE **10**, nearer EE 11 but not there. _(R2.9)_
- [x] **3.7** Add OpenRewrite's Boot 4 recipe to tooling guidance. _(R2.10)_
- [x] **3.8** Sweep `websphere-`, `weblogic-`, `wildfly-`, `java-to-springboot.md` and `cobol-to-java.md` for Boot 3 / Java 17 target claims. _(R2.1, R2.3)_

**Commit.**

---

## Phase 4 — Blocking vs reactive, presented neutrally

- [x] **4.1** Write the neutral decision section: both options with consequences, neither ranked, concrete criteria for when reactive earns its place. _(R3.1, design §4)_
- [x] **4.2** State the starting assumption — blocking Spring MVC + virtual threads — as a default to depart from, with the legacy-migration reasoning. _(R3.2, R3.3)_
- [x] **4.3** Rename four files, dropping "Reactive": `j2ee-to-springboot-reactive.md` → `j2ee-to-springboot.md`, and the titles inside `websphere-`, `weblogic-`, `wildfly-` and `dotnet-to-springboot.md`. _(R3.4)_
- [x] **4.4** Update the POWER.md dispatch table and every cross-reference for the renamed file **in the same commit**. _(design §7)_
- [x] **4.5** Rework R2DBC guidance so JPA is default and R2DBC the documented alternative, including validation criteria that currently *require* R2DBC. _(R3.5, design §4)_
- [x] **4.6** Add virtual-thread findings: pinning from `synchronized` on I/O paths (`ReentrantLock` remedy), and ThreadLocal / SecurityContext propagation. _(R3.6)_

**Commit.**

---

## Phase 5 — Cross-cutting files

- [x] **5.1** `frontend-to-spa.md`: generalise to any named framework plus undecided; extend the no-advocacy rule beyond React/Vue. _(R4.1, R4.2, R4.5)_
- [x] **5.2** `frontend-to-spa.md`: add the "Target-Specific Considerations" section — hybrid-embedding friction, meta-framework coupling, component-library continuity. Do **not** encode the AI-codegen claim. _(R4.4, R4.7)_
- [x] **5.3** `frontend-to-spa.md`: add Spring Security 7 CSRF-on-by-default as a high-priority finding. _(R4.6)_
- [x] **5.4** `cobol-to-java.md`: Spring Batch in-memory default affects batch migration guidance. _(R2.7)_
- [x] **5.5** `report-structure.md`: `.NET 8` in the Gantt examples (lines ~458, ~487).
- [x] **5.6** `evaluation-framework.md`: `.NET 8` references and the Mermaid diagram label.
- [x] **5.7** `aws-target-services.md`: Java 25 / Corretto 25, Tomcat 11, Lambda Java 25.

**Commit.**

---

## Phase 6 — Verify, version, deploy

- [x] **6.1** Verification sweep: 13-of-13 dispatch reachability after renames; all `inclusion: manual`; 11 report sections; 43 checklist items; no dollar amounts, effort estimates or ASCII-art diagrams; **zero stale `.NET 8` or `Spring Boot 3` target claims**.
- [x] **6.2** Confirm source-side legacy facts were not corrupted by the version sweep (Tomcat 9 is still javax, etc.). _(design §7)_
- [x] **6.3** Bump `POWER.md` to **4.0.0**; update description and keywords (Angular, Svelte, Boot 4.1, Java 25, virtual threads). _(R5.1, R5.2)_
- [x] **6.4** README version history entry for v4.0.0.
- [x] **6.5** Update `MIGRATION-NOTES.md` for the atx monolith. _(R5.3)_
- [x] **6.6** Sync `deploy/`, redeploy the installed power, verify byte-identical.
- [x] **6.7** Commit, tag `v4.0.0`, push both remotes, create releases on both.

---

## Explicitly not doing

- No `.NET 8/9 → .NET 10` source family row. _(R1.2)_
- No `4.x → 8 → 10` two-step. Direct is supported. _(R1.3)_
- No encoding of the React-vs-Vue AI-codegen claim. _(R4.7)_
- No changes to report section count, checklist structure, or the 3-pathway rule.
