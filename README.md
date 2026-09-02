# Legacy App Modernization Analyzer

A Kiro Power that provides enterprise-grade legacy codebase modernization analysis. Generates comprehensive AWS migration feasibility reports with visual architecture diagrams, proprietary dependency analysis, and strategic migration pathways.

## Supported Modernization Paths

Every analysis is defined by **two dimensions**: the **source platform** (detected from your codebase) and the **target platform** (which you choose — never assumed). The analyzer establishes both before producing a report.

| # | Source Platform | Target Platform | Description | Status |
|---|-----------------|-----------------|-------------|--------|
| 1 | .NET Framework | .NET 8 or **.NET 10** (LTS) + AWS | Windows-based .NET apps to cross-platform cloud-native, staying on C# | ✅ Stable |
| 2 | .NET Framework | Java Spring Boot + SPA + AWS | .NET apps migrated off C# to the Java stack | 🧪 BETA |
| 3 | IBM WebSphere | Spring Boot + AWS | J2EE/Jakarta EE to microservices | 🧪 BETA |
| 4 | Oracle WebLogic | Spring Boot + AWS | J2EE/Jakarta EE to microservices | 🧪 BETA |
| 5 | **Red Hat WildFly / JBoss EAP** | Spring Boot + AWS | J2EE/Jakarta EE to microservices | 🧪 BETA |
| 6 | Java (Tomcat/Jetty, Spring MVC, Struts, JSF, Dropwizard, Servlet/JSP) | Spring Boot 3.x + Java 17/21 + AWS | Plain Java SE / server-side Java (non-app-server) to Spring Boot 3 on Graviton | 🧪 BETA |
| 7 | COBOL/Mainframe | Java Spring Boot + AWS | CICS online, batch, DB2, VSAM to containerized Java on Graviton | 🧪 BETA |

### Cross-Cutting Dimensions

Two additional dimensions layer on top of a source → target path and are only applied when in scope:

| Dimension | Applies when |
|-----------|--------------|
| **Front-end / SPA rewrite** (React or Vue.js) | Target back end is Java Spring Boot **and** you name React or Vue as the front-end target. "Backend-only" is a first-class choice that skips the front-end rewrite entirely. |
| **Oracle → PostgreSQL** | Oracle is detected **and** you confirm database migration is in scope. Database migration scope is never assumed in either direction. |

> **Note**: WebSphere, WebLogic, WildFly/JBoss, Java, COBOL, and .NET → Java paths are in BETA. While functional, these paths may have limited coverage for some proprietary APIs and edge cases.

> **On path 2 (.NET → Java)**: this is a cross-language, cross-ecosystem migration (C# → Java) and is materially more complex than a same-ecosystem upgrade. Once you have chosen Java, the analyzer surfaces the risks, manual-effort items and automation opportunities for the Java target — it does **not** propose a two-step ".NET 8 first, then Java" bridge pathway. All three ranked pathways terminate in Java.

## Features

- **Two-Dimension Analysis**: Every report is scoped by a detected **source platform** and a user-chosen **target platform**. The target is always confirmed with you, never inferred from the source or defaulted
- **Auto-Detection**: Automatically identifies source platform from codebase indicators, using nested detection order so app-server apps (WebSphere/WebLogic/WildFly) are never mistaken for plain Java
- **Target Selection Prompts**: For .NET, asks whether the target is .NET 8, .NET 10, or Java Spring Boot; for any Spring Boot target, asks whether the front end is React, Vue.js, or backend-only
- **Platform-Specific Analysis**: Dedicated migration strategies for each source platform, dispatched through a single authoritative steering-file table (no implicit or pattern-matched loading)
- **Comprehensive Evaluation**: 18+ modernization areas assessed
- **Visual Architecture Diagrams**: Mermaid.js diagrams with component-level color coding
- **Package License Verification**: Queries NuGet/Maven APIs for license validation
- **Proprietary Dependency Analysis**: Impact assessment with code migration examples
- **.NET Pre-Migration Risk Surfacing (.NET 8 / .NET 10)**: When a .NET Framework → .NET 8 or .NET 10 migration is already committed, the analyzer surfaces every item the team needs to address before the port begins — automation-eligible items (AWS Transform for .NET / Windows Full Stack, EF6 → EF Core), manual-effort items (WCF, Web Forms, Active Directory auth), critical blockers (AppDomains, Remoting, CAS, Workflow Foundation, WCF server-side, Web Forms), platform risks (COM, GDI+, Registry, Windows services blocking Linux/Graviton), and upfront remediation in the Framework codebase before porting starts. The chosen runtime (.NET 8 vs .NET 10) changes the upgrade path and support-window discussion
- **.NET → Java Spring Boot Path**: For teams moving off C# entirely, sizes the rewrite from .NET Framework to a Java Spring Boot + SPA stack on AWS
- **WildFly / JBoss EAP Support**: Detects Red Hat WildFly and JBoss EAP applications via `jboss-*.xml` descriptors, `module.xml` module trees, and `org.jboss.*` / `org.wildfly.*` dependencies (with `standalone.xml` / `domain.xml` treated as corroborating-only to avoid false positives)
- **Active Directory / Windows SSO Detection**: Identifies AD authentication scenarios (Windows SSO vs Forms Auth) as critical migration blockers with scenario-specific modernization approaches
- **Java Modernization (Non-App-Server)**: Covers Java 8/11 → Java 17/21 JDK upgrades, `javax.*` → `jakarta.*` namespace migration, Spring Boot 1.x/2.x → 3.x staircase, Struts/JSF/Dropwizard/Servlet/JSP framework migration, WAR → executable JAR, JDK-internal API (`sun.*`) removal, removed module replacement (`java.xml.bind`, `java.activation`, `java.corba`), Log4j 1.x → Logback, and Java 17-compatibility matrix for common libraries (Hibernate, Spring Security, Jackson, Lombok, Mockito, etc.)
- **COBOL Modernization**: CICS online, batch processing, DB2, and VSAM migration patterns to Spring Boot with AWS Graviton targeting
- **COBOL Business Logic Extraction**: Exhaustive line-by-line extraction of business rules from COBOL PROCEDURE DIVISIONs, categorized into 10 rule types: input validation, calculation/processing, decision/routing, data access, inter-program communication, error handling, screen/interface, batch processing, security/authorization, and temporal/state management — each traced to specific paragraph names and code locations
- **COBOL Report Internal Consistency**: Built-in consistency rules ensuring summary-to-detail traceability, count verification across business rule categories, inventory completeness for VSAM files, DB2 tables, IMS databases, MQ queues, copybook mappings, and CICS transactions — with anti-pattern detection to prevent mismatched counts or phantom categories
- **COBOL-Specific Deep Evaluation**: Beyond standard framework areas — assesses reverse engineering readiness, platform-specific compiler behavior (rounding, EBCDIC collation, COMP/COMP-3 layout), undocumented business rules (tribal knowledge), regulatory compliance (SOX, PCI DSS, GDPR, HIPAA), performance/operational baselines, and coexistence/migration strategy with strangler fig architecture diagrams
- **Front-End / SPA Rewrite Sizing**: When React or Vue.js is the named front-end target, detects the current UI technology and sizes the rewrite. The front-end framework is always your input — the analyzer never compares or advocates React vs Vue. Backend-only is fully supported and skips this analysis
- **Scope-Aware Database Migration**: Detects the database footprint (engine, version, edition, data-access technology, stored-procedure/trigger/package volume) and states migration scope as an explicit question you must confirm. Recommends targets such as Aurora PostgreSQL only when you confirm migration is in scope. Programmes that keep the database are respected, not overridden
- **Evidence-for-Specialists Framing**: Every finding is framed as evidence a modernization specialist needs to plan effectively, never as a decision the reader should make. Reports contain no go/no-go decision tables or binary readiness verdicts and no failure case studies or cautionary tales; they use positive, solutions-oriented language and direct readers to AWS Modernization Specialists or authorized AWS Modernization Partners for the implementation strategy. Hard constraints (gating findings, critical blockers, "Impact If Not Modernized") are still stated plainly as evidence
- **Strategic Alignment**: AWS 7 Rs and Gartner TIME framework classification
- **Risk Assessment**: "Impact If Not Modernized" for every finding with probability ratings
- **3 Migration Pathways**: Ranked by weighted Recommendation Score with visual dot indicators
- **Dual Timeline Comparison**: Traditional vs Agentic AI-Accelerated timelines showing the value of AWS Transform + Kiro
- **Cost-Benefit Analysis**: Qualitative assessments by default (Low/Medium/High/Very High), with optional detailed pricing simulation available on request
- **Modernization Decision Tree (.NET)**: Visual Mermaid flowchart walking through feasibility checks, platform selection, and architecture decisions with a findings map showing exactly which codebase attributes drove the recommendation
- **Modernization Decision Tree (Java)**: Visual Mermaid flowchart evaluating JDK version, Spring usage, `javax.*`/`jakarta.*` namespace, removed JDK modules, workload I/O profile, packaging, and ARM64 readiness — producing a findings map that traces each scanned attribute to the recommended Spring Boot 3 target on ECS/EKS (Graviton where supported)
- **Modernization Decision Tree (COBOL)**: Visual Mermaid flowchart evaluating CICS online, DB2, VSAM, batch jobs, and business logic complexity to determine the optimal migration path to Spring Boot 3.x + Java 17 on ECS Fargate/Graviton, with a findings map documenting what was scanned and discovered
- **Hybrid Modernization Pattern**: Automatically detects un-modernizable dependencies (e.g., Crystal Reports, COM components, deprecated J2EE libraries, Java 8-only SDKs, JDK-internal APIs) and recommends a Legacy Component Isolation architecture with EC2 sidecar + API wrappers alongside the modernized stack

## Platform Detection

The analyzer automatically detects your **source platform**, then asks you to confirm the **target platform** before loading any steering files. Source detectors run in a nested order and stop at the first positive match, so an app-server application is never misclassified as plain Java.

### .NET Detection
- Files: `.sln`, `.csproj`, `.vbproj`, `web.config`, `packages.config`, `appsettings.json`
- AD/SSO indicators: `<authentication mode="Windows" />`, `WindowsIdentity`, `Membership.ValidateUser()`, `System.DirectoryServices`

### WebSphere Detection
- Files: `ibm-web-bnd.xml`, `ibm-web-ext.xml`, `ibm-application-bnd.xml`, `ibm-ejb-jar-bnd.xml`
- Dependencies: `com.ibm.websphere.*`, `com.ibm.ws.*`, `com.ibm.mq.*`

### COBOL Mainframe Detection
- Files: COBOL source (`.cbl`), copybooks (`.cpy`), JCL (`.jcl`), BMS maps (`.bms`)
- Dependencies: CICS commands, DB2 SQL, VSAM file operations, MQ Series
- Indicators: `EXEC CICS`, `EXEC SQL`, `COPY` statements, `CALL`/`XCTL` program transfers

### WebLogic Detection
- Files: `weblogic.xml`, `weblogic-application.xml`, `weblogic-ejb-jar.xml`, `plan.xml`
- Dependencies: `weblogic.*`, `oracle.weblogic.*`, `com.bea.*`, `oracle.toplink.*`

### WildFly / JBoss EAP Detection
- Sufficient files: `jboss-web.xml`, `jboss-deployment-structure.xml`, `jboss-ejb3.xml`, `module.xml` under a `modules/` tree, `jboss-cli` scripts
- Dependencies: `org.jboss.*`, `org.wildfly.*`, `org.infinispan.*`, `org.jboss.logging`
- Corroborating only (not sufficient alone): `standalone.xml`, `domain.xml`

### Plain Java Detection (non-app-server)
- Positive files: `pom.xml`, `build.gradle`, `build.gradle.kts`, `src/main/java/`, `src/main/webapp/WEB-INF/web.xml`
- Frameworks detected: Spring Boot (1.x/2.x/3.x), Spring MVC (XML or annotation), Struts 1/2, JSF/Jakarta Faces, Dropwizard, Micronaut, Quarkus, Vaadin, plain Servlet/JSP
- JDK version signals: `maven.compiler.source/target/release`, Gradle `sourceCompatibility`/`languageVersion`, `.java-version`, `.sdkmanrc`, Dockerfile base image
- Negative signals (all must be absent to confirm this path): any IBM `ibm-*.xml` / `com.ibm.websphere.*` imports, `weblogic*.xml` / `weblogic.*` / `oracle.weblogic.*` / `com.bea.*` imports, `jboss-*.xml` / `module.xml` / `org.jboss.*` / `org.wildfly.*` imports

### Target Confirmation
Once the source is detected, the analyzer asks you to choose the target:
- **.NET source** → .NET 8, .NET 10, or Java Spring Boot
- **Any Spring Boot target** → React, Vue.js, or backend-only for the front end
- **Oracle detected** → confirms whether Oracle → PostgreSQL is in scope

## Prerequisites

- Kiro IDE
- `uvx` installed (for fetch MCP server)
  - Install: `pip install uv` or see [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)

## Usage

Activate by mentioning:
- "analyze this codebase"
- "modernization assessment"
- "migration feasibility"
- "legacy application"
- "AWS migration"
- "containerize app"
- "modernize to Spring Boot"
- "modernize to .NET 8"
- "modernize to .NET 10"
- ".NET modernization"
- ".NET to Java"
- ".NET to Spring Boot"
- "cross-platform migration"
- "WebSphere migration"
- "WebLogic migration"
- "WildFly migration"
- "JBoss migration"
- "JBoss EAP to Spring Boot"
- "J2EE modernization"
- "Java modernization"
- "Java 8 to 17"
- "Java 11 to 17"
- "Java 11 to Spring Boot"
- "Tomcat to Spring Boot"
- "Struts to Spring Boot"
- "JSF to Spring Boot"
- "Dropwizard to Spring Boot"
- "javax to jakarta migration"
- "COBOL modernization"
- "mainframe migration"
- "COBOL to Java"
- "mainframe to cloud"
- "JSP to React"
- "JSF to Vue"
- "SPA migration"
- "Oracle to PostgreSQL"

### Example

```
User: analyze this codebase and generate a modernization report
```

The power will:
1. Detect source platform (.NET, WebSphere, WebLogic, WildFly/JBoss, plain Java, or COBOL)
2. Ask you to confirm the target platform (e.g. .NET 8/.NET 10 vs Java; React/Vue/backend-only front end; Oracle → PostgreSQL scope)
3. Load common framework files first (report structure, evaluation, AWS services), then the path-specific steering files from the authoritative dispatch table
4. Scan codebase incrementally (context-aware for large projects)
5. Detect database technology and state migration scope as an explicit question
6. Verify package licenses via registry APIs
7. Generate `yymmddhhmm_MODERNIZATION_REPORT.md` (timestamped: YY=year, MM=month, DD=day, HH=hour, MM=minutes)

## Output

Report structure is defined by `steering/report-structure.md` (single source of truth) — **11 numbered sections**:

1. **Professional Advisory Notice** - Consultation disclaimer directing readers to AWS Modernization Specialists or authorized partners
2. **Executive Summary** - Strategic verdict, feasibility score, risk of inaction, and stated caveats where gating findings or open questions affect confidence
3. **Visual Architecture State** - Current and target state diagrams (Mermaid, colour-coded with a legend)
4. **Critical Findings Matrix** - 10+ findings with priorities, including gating findings in the highest band, the Windows lock-in or proprietary-vendor-API clusters, and open questions requiring customer input
5. **Proprietary Dependency Analysis** - License verification, target-compatible version availability, migration examples
6. **Database Analysis & Migration Opportunity** - Footprint, logic held in the database, and the migration scope question stated explicitly
7. **Recommended Pathways** - Exactly 3 pathways with:
   - Weighted Recommendation Scores (6 factors: Long-term Value, Implementation Risk, Cost Efficiency, Time to Value, Team Readiness, Business Continuity)
   - Visual dot indicator scoring matrix (●●●●●●●●●○ format)
   - Quadrant chart for effort vs value positioning
   - Pros/cons tables and risk assessments
8. **Next Steps** - Recommended pathway implementation roadmap with:
   - Dual timeline comparison (Traditional vs Agentic AI-Accelerated)
   - Tool automation impact analysis (AWS Transform, Kiro, SCT, DMS)
   - Timeline reduction metrics (typically 70-80% faster with GenAI tools)
9. **Cost-Benefit Analysis** - Pathway comparison (qualitative; no dollar amounts by default, with optional detailed pricing simulation on request)
10. **Solution Structure Summary** - Projects, modules and complexity
11. **Conclusion** - Assessment and success factors

The **Decision Tree Findings Map** (.NET / Java / COBOL) is a node-by-node walkthrough showing what was scanned, what was found, and the route taken through the decision tree. It is presented within the sections above rather than as a section of its own.

## Project Structure

```
legacy-app-modernization-analyzer/
├── POWER.md                              # Main power definition + authoritative dispatch table
├── mcp.json                              # MCP server configuration (fetch)
├── README.md                             # This file
└── steering/
    ├── report-structure.md               # Report format standards (AUTHORITATIVE) — loaded first
    ├── evaluation-framework.md           # Universal evaluation areas
    ├── aws-target-services.md            # AWS service mappings
    ├── dotnet-to-aws.md                  # .NET Framework → .NET 8 / .NET 10 + AWS
    ├── dotnet-to-springboot.md           # .NET Framework → Java Spring Boot + SPA
    ├── websphere-to-springboot.md        # WebSphere → Spring Boot
    ├── weblogic-to-springboot.md         # WebLogic → Spring Boot
    ├── java-to-springboot.md             # Plain Java (Tomcat/Jetty, Spring MVC, Struts, JSF, Dropwizard) → Spring Boot 3.x + Java 17/21
    ├── wildfly-to-springboot.md          # WildFly / JBoss EAP → Spring Boot
    ├── cobol-to-java.md                  # COBOL → Java 17+ Spring Boot 3.x (mechanical data inventory + internal consistency rules)
    ├── j2ee-to-springboot-reactive.md    # Shared J2EE app-server module (EJB, JTA, vendor JNDI) + required J2EE/Java analysis depth
    ├── frontend-to-spa.md                # Cross-cutting: current front-end detection and SPA rewrite sizing (React or Vue)
    └── oracle-to-postgresql.md           # Cross-cutting: Oracle → PostgreSQL workstream (loaded only when in scope)
```

All 13 steering files are `inclusion: manual` and every one is reachable from the POWER.md Step 2 dispatch table. Nothing loads implicitly, by pattern match, or by transclusion from another steering file.

## Version History

### v3.1.0 - Report Tone and Framing Rules Now Ship With the Power
- The analyzer's tone and framing rules are now part of `steering/report-structure.md`, so they apply to **every** generated report. Previously they lived only in workspace-level steering, which meant they governed development of this power but never reached an installed copy
- Added as authoritative rules 17–21 plus a dedicated **Report Tone and Framing** section: findings are evidence rather than instructions; no go/no-go decision tables or binary readiness verdicts; no failure case studies; always direct readers to AWS Modernization Specialists or authorized partners; positive, solutions-oriented language
- Clarified how this interacts with the rest of the spec: gating findings, critical blockers and "Impact If Not Modernized" are still required and stated plainly — surfacing a hard constraint is evidence, not a verdict
- Repo hygiene: exclusions moved from the local-only `.git/info/exclude` into a tracked `.gitignore`, and `.kiro/hooks/`, `.kiro/steering/` and `.kiro/specs/` are now tracked so the automation, ground rules and design records survive a fresh clone

### v3.0.0 - Six Source Families, Two Dimensions, Questionnaire-Grade Depth
- Two-dimension analysis model: detected **source** + user-confirmed **target** (target never assumed)
- **New path**: .NET Framework → Java Spring Boot + SPA (BETA)
- **New path**: Red Hat WildFly / JBoss EAP → Spring Boot (BETA), with the WildFly-specific effort profile stated rather than the commercial-app-server stereotype applied
- **New target**: .NET 10 alongside .NET 8, with the support-window consequence surfaced and upgrade paths modelled as `3→10`, `4→10` and `3→4→10`
- **New cross-cutting dimension**: front-end / SPA rewrite sizing (React or Vue — always your input, never a recommendation), including whether a REST API already exists as the dominant sizing question
- **New cross-cutting dimension**: Oracle → PostgreSQL as a full workstream, loaded only when you confirm it is in scope
- **Scope-aware database analysis**: the footprint is reported and the migration scope question asked; no engine change is recommended by default
- **Questionnaire-grade analysis depth** derived from real customer qualification workbooks: a 16-item mandatory baseline inventory applied on every path, platform-specific depth per path, gating findings that outrank ordinary findings, and an explicit derivable-from-source vs requires-customer-input contract so open questions are named rather than guessed
- Authoritative steering-file dispatch table; all 13 steering files `inclusion: manual` with no implicit, pattern-matched or transcluded loading
- Windows containers documented as a lower-risk interim hop, distinct from Linux/Graviton containerization
- Fixed: duplicated .NET decision-tree section merged into one; ASCII-art architecture diagram in the evaluation framework converted to Mermaid with a colour legend

### v2.0.0 - Legacy App Modernization Analyzer
- Two-dimension analysis model: detected **source** + user-confirmed **target** (target never assumed)
- Multi-platform support: .NET, WebSphere, WebLogic, WildFly/JBoss EAP, plain Java, COBOL
- .NET target choice: .NET 8, .NET 10, or Java Spring Boot
- .NET → Java Spring Boot migration path
- Front-end scope selection: React, Vue.js, or backend-only (framework is user input, never a recommendation)
- Scope-aware database migration with explicit Oracle → PostgreSQL confirmation
- Authoritative steering-file dispatch table (manual inclusion, no implicit or pattern-matched loading)
- COBOL Mainframe to Java Spring Boot modernization path (BETA)
- Platform auto-detection with nested ordering to prevent app-server/plain-Java misclassification
- Consolidated steering files with authoritative report structure
- Expanded database support (SQL Server, Oracle, DB2)

### v1.x - .NET Modernization Analyzer
- Original .NET Framework → .NET 8 analyzer
- NuGet license verification
- Architecture diagram color coding

## License

Apache 2.0
