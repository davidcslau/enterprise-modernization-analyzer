# Tasks — Merge Forks, Six Paths, Questionnaire-Grade Depth

Requirement IDs refer to `requirements.md`. Design sections refer to `design.md`.

---

## Phase 0 — Safety

- [x] **0.1** Create branch `feat/merge-six-paths`. _(P1)_
- [x] **0.2** Set `"enabled": false` in `.kiro/hooks/copy-to-deploy.kiro.hook`. _(P2)_
- [x] **0.3** Set `"enabled": false` in `.kiro/hooks/update-readme-on-power-change.kiro.hook`. _(P2)_
- [x] **0.4** Read both hook files back to confirm the toggle took — `.kiro/*` is
      git-excluded, so `git status` cannot verify this. _(P2)_
- [x] No backup task needed — `~/analyzer-fork-backup-20260901` verified present. _(P5)_

**Commit:** none (only untracked `.kiro/` changed).

---

## Phase 1 — Merge A into B

- [x] **1.1** Copy `steering/dotnet-to-springboot.md` from A, **body only**, with
      fresh front matter `inclusion: manual`. Confirm A's front matter is absent
      and A's file is unmodified. _(R1.2, R3.1)_
- [x] **1.2** **Commit 1.1 alone**, before any other change. _(R1.3)_
- [x] **1.3** Apply A's delta to `dotnet-to-aws.md` — "Analyzer Mission: Risk
      Surfacing for .NET 8 Migration" after the title. _(R1.4)_
- [x] **1.4** Apply A's delta to `websphere-to-springboot.md` — "Shared J2EE →
      Spring Boot Reactive Patterns", with the `#[[file:]]` line replaced by a
      plain-text pointer to POWER.md dispatch. _(R1.4, R3.3, design §1.2)_
- [x] **1.5** Same for `weblogic-to-springboot.md`, worded for WebLogic. _(R1.4, R3.3)_
- [x] **1.6** Apply A's front-matter change to `j2ee-to-springboot-reactive.md`:
      remove `fileMatchPattern`, set `inclusion: manual`, reword A's explanatory
      comment to describe POWER.md dispatch instead of `#[[file:]]`. _(R1.4, R3.1, R3.3)_
- [x] **1.7** Set `inclusion: manual` on the three files currently
      `inclusion: always`: `aws-target-services.md`, `evaluation-framework.md`,
      `report-structure.md`. _(R3.1)_
- [x] **1.8** Rewrite `POWER.md` Step 1 as two-dimensional detection: source
      order `.NET → WebSphere → WebLogic → WildFly → plain Java → COBOL`;
      plain-Java detector stays last with negative signals extended to WildFly
      markers; then the per-source target prompt; no defaults; skip the prompt if
      the target was already stated; retain B's ambiguity rules and user
      override. _(R4.1–R4.5, design §2)_
- [x] **1.9** Rewrite `POWER.md` Step 2 as the single authoritative dispatch
      table, every row led by the three universal files, `frontend-to-spa.md`
      conditional on the front-end answer, `oracle-to-postgresql.md` as an
      orthogonal conditional row. _(R3.2, R3.4, design §3)_
- [x] **1.10** Add the .NET → Java row to `## Supported Modernization Paths` in
      `POWER.md`. Present WebSphere/WebLogic/WildFly as one J2EE family. _(R2, R2.1)_
- [x] **1.11** Add the .NET → Java row to the README paths table, marked BETA
      consistent with the existing status column. _(R2)_

**Commit:** Phase 1.
**→ CHECKPOINT 1. STOP for user review. Do not start Phase 2.** _(P4)_

---

## Phase 2 — .NET 10, the 3.x pre-step, database scope fix

In `steering/dotnet-to-aws.md`:

- [x] **2.1** Add .NET 10 as a selectable target alongside .NET 8, covering
      directly that .NET 8's support window ends before a long programme
      completes. _(R11.1)_
- [x] **2.2** Add the 3.x → 4.x pre-upgrade step (AWS Transform Custom), modelling
      `3→10`, `4→10` and `3→4→10` explicitly, each hop flagged as adding
      transformation-defect surface. _(R11.2)_
- [x] **2.3** Add Windows containers as a lower-risk interim hop, distinct from
      full Linux/Graviton containerization. _(R11.3)_
- [x] **2.4** **Fix the database default.** Replace the unconditional SQL Server →
      Aurora PostgreSQL recommendation with: report the footprint (version,
      edition, stored-procedure / function / trigger / SSIS counts, data access
      technology), then state that database migration may be explicitly out of
      scope, in which case the target design must deliberately avoid database
      change. Recommend Aurora only on confirmation that DB migration is in
      scope. _(R10.1, R10.3)_
- [x] **2.5** Fold in the .NET questionnaire depth: application type, primary
      language with VB.NET friction, the full Windows lock-in cluster, Visual
      Studio and build toolchain, SQL Server footprint. _(R7)_
- [x] **2.6** Mirror the .NET-specific depth into `dotnet-to-springboot.md` where
      it applies to a Java target. Verify I6 holds — no ".NET 8 first, then Java"
      bridge pathway anywhere in that file. _(R7, I6)_
- [x] **2.7** Add the universal criteria and the honesty rule to
      `evaluation-framework.md`. _(R5, R6)_

**Commit:** Phase 2.

---

## Phase 3 — WildFly / JBoss EAP

- [x] **3.1** Create `steering/wildfly-to-springboot.md`, `inclusion: manual`,
      structured to match the WebSphere/WebLogic skeleton exactly. _(R2.2, design §6.1)_
- [x] **3.2** Detection: `jboss-web.xml`, `jboss-deployment-structure.xml`,
      `jboss-ejb3.xml`, `standalone.xml`, `domain.xml`, `jboss-cli`, `module.xml`;
      imports `org.jboss.*`, `org.wildfly.*`, `org.infinispan.*`,
      `org.jboss.logging`, `org.hibernate.*` when paired with JBoss modules.
      `standalone.xml`/`domain.xml` specified as corroborating, not sufficient. _(R2.2, design §2.1)_
- [x] **3.3** Strategy bank: JBoss Modules → flat classpath; `standalone.xml`
      subsystems → `application.yml`; Undertow → embedded Tomcat/Netty;
      Infinispan → Spring Cache + ElastiCache; HornetQ/Artemis → Amazon MQ/SQS/MSK;
      JBoss Remoting → REST/gRPC; Elytron/PicketLink/legacy security domains →
      Spring Security; Narayana → `@Transactional` / R2DBC; `datasources` JNDI →
      Spring DataSource; CLI deployment → container image; EAP subscription cost
      as a business driver.
- [x] **3.4** State the WildFly *advantage* — Hibernate and Jakarta EE alignment
      often already closer to Spring Boot 3 than WebSphere or WebLogic, so the
      effort profile genuinely differs. _(design §6.1)_
- [x] **3.5** Fold in the J2EE questionnaire depth. _(R8)_
- [x] **3.6** Wire WildFly into: POWER.md paths table, POWER.md detection chain
      (already done in 1.8), POWER.md dispatch table, README paths table,
      README detection section, `aws-target-services.md`. _(R2, R3.4)_
- [x] **3.7** Add the J2EE questionnaire depth to `websphere-to-springboot.md`,
      `weblogic-to-springboot.md` and `java-to-springboot.md`. _(R8)_

**Commit:** Phase 3.

---

## Phase 4 — Front-end / SPA dimension

- [x] **4.1** Create `steering/frontend-to-spa.md`, `inclusion: manual`. _(R12, design §6.2)_
- [x] **4.2** Current front-end detection and screen inventory: JSP with
      scriptlet density, JSF/Facelets (`.xhtml`, PrimeFaces/RichFaces/IceFaces),
      Struts tags, Thymeleaf, Velocity/FreeMarker, Web Forms (`.aspx` +
      code-behind), Razor (`.cshtml`), jQuery/Dojo/ExtJS/GWT/Vaadin/Wicket, COBOL
      BMS maps / 3270 screens. Inventory = page count, form count, custom tag
      libraries, server-side includes, master pages and templates. _(R12)_
- [x] **4.3** The dominant sizing question — does a REST API already exist?
      Placed before the full-vs-hybrid discussion. Existing API → SPA drops in.
      JSP/Web-Forms-heavy with view-layer logic → full rewrite **plus** a
      business-logic extraction workstream. Must not conflate the two. _(R12.2)_
- [x] **4.4** Full SPA vs hybrid, both with consequences, customer chooses. _(R12)_
- [x] **4.5** Business logic in the view layer, quantified. _(R12)_
- [x] **4.6** Session and auth interaction: server-side HTTP session and sticky
      sessions block SPA + stateless scaling; container-managed auth, JAAS,
      Windows Auth, Forms Auth → JWT or OAuth2/OIDC with Cognito; CSRF, CORS and
      token-storage consequences. _(R12)_
- [x] **4.7** What does not port cleanly, as its own risk class: Crystal Reports,
      SSRS/RDLC, JasperReports, print and PDF generation, file upload/download
      flows, Excel export, applets, ActiveX, browser plugins, page-oriented
      `window.print`. _(R12)_
- [x] **4.8** Target-side patterns: BFF; npm/Vite build integrated into
      Maven/Gradle; Spring Boot static resources vs S3 + CloudFront; route-by-route
      strangler migration; OpenAPI contract generation as the seam between the
      front-end and back-end workstreams. _(R12)_
- [x] **4.9** COBOL BMS map → screen definition → SPA view, mapping the 3270
      field and attribute model onto form fields and validation. Reference it
      from `cobol-to-java.md`. _(R12)_
- [x] **4.10** Verify R12.1 by inspection: no React-vs-Vue comparison and no
      advocacy of either anywhere in the file.
- [x] **4.11** Add the COBOL questionnaire depth to `cobol-to-java.md` — dialect
      and compiler, CICS coupling depth, DB2 vs VSAM split, JCL/scheduler
      coupling, RACF/ACF2/Top Secret as the auth finding. _(R9)_

**Commit:** Phase 4.

---

## Phase 5 — Oracle → PostgreSQL

- [x] **5.1** Create `steering/oracle-to-postgresql.md`, `inclusion: manual`,
      dispatched only when Oracle → PostgreSQL is confirmed in scope. _(R13, design §6.3)_
- [x] **5.2** Oracle version, edition and RAC; Enterprise-only features in use
      (partitioning, advanced compression, RAC) with PostgreSQL workarounds. _(R13)_
- [x] **5.3** PL/SQL inventory — procedures, functions, packages, triggers,
      materialized views, with counts and volume, as the most labour-intensive
      part. _(R13)_
- [x] **5.4** Oracle-specific SQL constructs: `CONNECT BY` → `WITH RECURSIVE`,
      `DECODE` → `CASE`, `NVL` → `COALESCE`, `(+)` → ANSI joins, `MERGE`,
      `ROWNUM` → `LIMIT`, `SYS_CONTEXT`, `DUAL`, `.NEXTVAL` → `nextval()`,
      `TO_DATE` format differences. _(R13)_
- [x] **5.5** Empty-string-is-NULL as a **silent behaviour-change risk**, in its
      own callout, separated from the syntax table. _(R13.1, design §6.3)_
- [x] **5.6** Oracle-proprietary features: Oracle Text, Spatial, Advanced
      Queuing → SQS/SNS, `DBMS_SCHEDULER` → EventBridge Scheduler or Spring
      Scheduling, `UTL_FILE` → S3, `UTL_HTTP` → HTTP client, `DBMS_OUTPUT`,
      `DBMS_LOB`. _(R13)_
- [x] **5.7** Data types: `NUMBER` → `numeric`/`bigint`, `VARCHAR2` → `varchar`,
      `DATE` → `timestamp`, `CLOB`/`BLOB` → `text`/`bytea`, `RAW`. _(R13)_
- [x] **5.8** Data access impact: Hibernate dialect change, Oracle-specific
      HQL/JPQL, MyBatis and raw JDBC carrying Oracle syntax. _(R13)_
- [x] **5.9** Sizing: schema size, table count, largest table row count → AWS
      SCT/DMS vs manual, and the downtime window. Oracle licence elimination as
      an explicit business driver. _(R13)_
- [x] **5.10** Add the conditional dispatch row to POWER.md and note the
      asymmetry: .NET assumes DB migration out of scope, J2EE assumes it in
      scope, neither is ever assumed silently. _(R10.2, R10.3)_

**Commit:** Phase 5.
**→ CHECKPOINT 2. STOP for user review. Do not start Phase 6.** _(P4)_

---

## Phase 6 — Cleanup and verification

- [x] **6.1** Fix the duplicated decision tree in `dotnet-to-aws.md`: read both
      blocks in full, fold any unique wording from the second into the survivor,
      then merge to one section keeping the single Mermaid diagram and the first
      copy's richer "Decision Tree Mapping Instructions" table plus its ✅/❌
      guidance. _(R14.1)_
- [x] **6.2** Convert the box-drawing diagram in `evaluation-framework.md` to
      Mermaid with a colour legend, preserving semantics: modernized app ↔
      REST/gRPC ↔ EC2 legacy component host containing an API wrapper service. _(R14.2)_
- [x] **6.3** Bump `version` in `POWER.md` front matter to `3.0.0`; update
      `description` and `keywords` to include WildFly, JBoss, React, Vue, SPA,
      PostgreSQL, Oracle, .NET 10. _(R15)_
- [x] **6.4** Verification sweep:
  - every steering file is `inclusion: manual`
  - every steering file is reachable from the POWER.md dispatch table
  - no `fileMatch` and no `#[[file:` anywhere
  - no orphaned files
  - `report-structure.md` still has exactly 11 numbered sections
  - no dollar amounts, no hour/day estimates, no ASCII art in new content
  - I6 holds in `dotnet-to-springboot.md`
  _(R3.1, R3.4, I2, I3, I4)_
- [x] **6.5** Write `MIGRATION-NOTES.md` in the repo root: every change needing
      mirroring into
      `atx-app-mod-analyzer/atx-txfrm-defn/transformation_definition.md`, section
      by section, noting that the monolith uses a different 13-section structure
      with COBOL "Data Inventory" and "Business Logic Extraction Summary"
      promoted to 5 and 6 and "Decision Tree Findings Map" folded into 4. Do not
      regenerate the monolith. Do not run `atx custom def publish`. _(R16)_
- [x] **6.6** Re-enable both hooks (`"enabled": true`). _(P2)_
- [x] **6.7** Let the hooks run one sync pass so `deploy/` and `README.md` come
      back into line.
- [x] **6.8** Confirm the README paths table still lists all 6 source families /
      7 rows. If the hook mangled it, fix the README and say so explicitly.
- [x] **6.9** Final commit. **Do not push.** _(I8)_
- [x] **6.10** Report: files added, files changed with line counts, the paths now
      supported, and anything not completed.

---

## Deferred / explicitly not doing

- Regenerating or publishing the atx monolith. _(R16.1, R16.3)_
- Editing `.kiro/steering/analyzer-ground-rules.md`. _(I5)_
- Editing fork A or `atx-app-mod-analyzer/`. _(I8)_
- Pushing any branch. _(I8)_
- Adding a questionnaire section or answer tables to the report. _(out of scope)_
