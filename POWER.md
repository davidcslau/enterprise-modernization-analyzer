---
name: "legacy-app-modernization-analyzer"
displayName: "Legacy App Modernization Analyzer"
description: "Analyzes legacy enterprise codebases (.NET, WebSphere, WebLogic, COBOL/Mainframe, plain Java on Tomcat/Jetty) and generates comprehensive AWS modernization feasibility reports with visual architecture diagrams, dependency analysis, and migration pathways"
keywords: [".NET", "WebSphere", "WebLogic", "COBOL", "Mainframe", "Java", "Spring Boot", "Struts", "JSF", "Dropwizard", "Tomcat", "Jetty", "modernization", "migration", "legacy", "AWS", "containerization", "microservices", "J2EE", "Jakarta"]
version: "2.0.0"
---

# Legacy App Modernization Analyzer

## Overview

This power provides elite-level enterprise architecture analysis for legacy application modernization projects. It supports multiple source platforms and generates comprehensive feasibility reports with visual diagrams, following a rigorous evaluation framework and migration strategy bank.

## Supported Modernization Paths

Six source families, seven source → target combinations. The J2EE family covers three
application server vendors, each with its own steering file because their proprietary
APIs differ enough to warrant separate treatment.

| # | Source Platform | Target Platform | Steering File |
|---|-----------------|-----------------|---------------|
| 1 | .NET Framework | .NET 8 **or .NET 10** + AWS | `steering/dotnet-to-aws.md` |
| 2 | .NET Framework | Java Spring Boot + **React or Vue.js** + AWS | `steering/dotnet-to-springboot.md` |
| 3 | J2EE — IBM WebSphere | Spring Boot + React/Vue + AWS | `steering/websphere-to-springboot.md` |
| 4 | J2EE — Oracle WebLogic | Spring Boot + React/Vue + AWS | `steering/weblogic-to-springboot.md` |
| 5 | J2EE — Red Hat WildFly / JBoss EAP | Spring Boot + React/Vue + AWS | `steering/wildfly-to-springboot.md` |
| 6 | Java SE 8 / plain Java (Tomcat, Jetty, Spring MVC, Struts, JSF, Dropwizard, Servlet/JSP) | Spring Boot 3.x + Java 17/21 + React/Vue + AWS | `steering/java-to-springboot.md` |
| 7 | COBOL / Mainframe | Java Spring Boot + React/Vue + AWS | `steering/cobol-to-java.md` |

Two cross-cutting dimensions apply on top of a source → target combination, and are
dispatched conditionally:

| Dimension | Steering File | Applies when |
|-----------|---------------|--------------|
| Front-end / SPA rewrite | `steering/frontend-to-spa.md` | Target is Java Spring Boot **and** the user has named React or Vue as the front-end target |
| Oracle → PostgreSQL | `steering/oracle-to-postgresql.md` | Oracle is detected **and** the user confirms database migration is in scope |

## Workflow

### Step 1: Detection — Two Dimensions

Every analysis is defined by **two** dimensions, and both must be established before any
steering file is loaded:

1. **Source platform** — determined by scanning the codebase (Step 1A).
2. **Target platform** — determined by asking the user (Step 1B). Never inferred from the
   source, and never defaulted.

Getting a report out of the wrong combination is worse than asking one question, so do not
proceed to Step 2 until both dimensions are known.

#### Step 1A: Detect the Source Platform

Scan the codebase to identify the source platform. **Order matters** — the signals are
nested, because every WebSphere, WebLogic and WildFly application is also a Java
application with `pom.xml` and `src/main/java`. Run detectors in this sequence and stop at
the first positive match:

**1a. Detect .NET:**
- Look for: `.sln`, `.csproj`, `.vbproj`, `web.config`, `packages.config`, `appsettings.json`
- If found → source is **.NET Framework**. Go to Step 1B to establish the target.

**1b. Detect WebSphere:**
- Look for: `ibm-web-bnd.xml`, `ibm-web-ext.xml`, `ibm-application-bnd.xml`, `ibm-ejb-jar-bnd.xml`, `was.policy`, `server.xml` (Liberty)
- JAR dependencies: `com.ibm.websphere.*`, `com.ibm.ws.*`, `com.ibm.wsspi.*`, `com.ibm.mq.*`
- If found → source is **J2EE / IBM WebSphere**

**1c. Detect WebLogic:**
- Look for: `weblogic.xml`, `weblogic-application.xml`, `weblogic-ejb-jar.xml`, `plan.xml`, `weblogic-cmp-rdbms-jar.xml`
- JAR dependencies: `weblogic.*`, `oracle.weblogic.*`, `com.bea.*`, `oracle.toplink.*`
- If found → source is **J2EE / Oracle WebLogic**

**1d. Detect WildFly / JBoss EAP:**
- Sufficient signals (any one confirms the path): `jboss-web.xml`, `jboss-deployment-structure.xml`, `jboss-ejb3.xml`, `jboss-cli` scripts, `module.xml` under a `modules/` tree
- JAR dependencies: `org.jboss.*`, `org.wildfly.*`, `org.infinispan.*`, `org.jboss.logging`; and `org.hibernate.*` **when paired with** JBoss module or subsystem markers
- Corroborating signals (NOT sufficient alone): `standalone.xml`, `domain.xml`. These filenames appear in unrelated projects, so a match on them confirms WildFly only when accompanied by a `jboss-*` / `org.jboss.*` / `org.wildfly.*` signal.
- If found → source is **J2EE / Red Hat WildFly or JBoss EAP**

**1e. Detect Plain Java (non-app-server):**
- Positive signals: `pom.xml`, `build.gradle`, `build.gradle.kts`, `src/main/java`, `src/main/webapp/WEB-INF/web.xml`, Spring Boot / Spring MVC / Struts / JSF / Dropwizard / Micronaut / Quarkus imports
- Negative signals (**MUST** all be absent — if any is present, fall back to the matching app-server path at 1b, 1c or 1d):
  - WebSphere: any IBM `ibm-*.xml`, `was.policy`, `com.ibm.websphere.*` / `com.ibm.ws.*` / `com.ibm.wsspi.*` imports
  - WebLogic: `weblogic*.xml`, `plan.xml`, `weblogic.*` / `oracle.weblogic.*` / `com.bea.*` imports
  - WildFly / JBoss EAP: `jboss-web.xml`, `jboss-deployment-structure.xml`, `jboss-ejb3.xml`, `module.xml` under `modules/`, `org.jboss.*` / `org.wildfly.*` / `org.infinispan.*` imports
- If positive signals found AND all negative signals absent → source is **Java SE / plain Java**
- This detector stays **last among the Java-family detectors**. Placing it earlier would swallow all three app-server paths.

**1f. Detect COBOL/Mainframe:**
- Look for: `*.cbl`, `*.cob`, `*.cpy`, `*.CPY`, `*.bms`, `*.BMS`, `*.jcl`, `*.JCL`, `*.csd`
- Code patterns: `EXEC CICS`, `EXEC SQL`, `WORKING-STORAGE SECTION`, `PROCEDURE DIVISION`
- If found → source is **COBOL / Mainframe**
- **MANDATORY for COBOL:** Execute the Mechanical Data Inventory Extraction AND Mechanical Business Rule Extraction procedures defined in the steering file. The Business Logic Extraction section with all 10 categories MUST appear in the report. This is not optional — it is the most critical section for COBOL modernization.

**1g. Ambiguous or unmatched cases:**
- If both Java build files AND WebSphere/WebLogic/WildFly markers are present, prefer the app-server guide (it covers the Java fundamentals too)
- If markers for **two different** app servers are present, ask the user which one is authoritative — do not merge two vendor guides in a single pass
- If no platform matches, ask the user to confirm the source platform before proceeding
- The user may explicitly tell the analyzer which steering file to use (e.g., "treat this as the Java path"), and an explicit user instruction always overrides detection

#### Step 1B: Establish the Target Platform

**MANDATORY.** Stop and ask. Do **NOT** assume a default. Do **NOT** compare, rank or
explain the options — the user is already aware of the platform choice, and choosing for
them is not this analyzer's job.

**If the user's opening message already stated a target, skip the relevant prompt** and
proceed with what they said.

**When the source is .NET**, ask which target runtime:

> I've detected a **.NET Framework codebase**. Which target are you modernizing to?
>
> 1. **.NET 8 (LTS) on AWS** — stay on C#, upgrade the framework
> 2. **.NET 10 (LTS) on AWS** — stay on C#, upgrade the framework
> 3. **Java Spring Boot + SPA on AWS** — migrate to Java
>
> Reply with "1" / ".NET 8", "2" / ".NET 10", or "3" / "Java".

- Reply 1 or 2 → target is **.NET 8 / .NET 10**. Record which one; it changes the upgrade path and the support-window discussion.
- Reply 3 → target is **Java Spring Boot**. Then also ask the front-end question below.
- Ambiguous reply → ask one clarifying question before proceeding.

**When the target is Java Spring Boot** — that is, any WebSphere, WebLogic, WildFly, plain
Java or COBOL source, and .NET with reply 3 — ask about the front-end:

> Target back end is **Java Spring Boot on AWS**. What is in scope for the front end?
>
> 1. **React**
> 2. **Vue.js**
> 3. **Backend-only** — no front-end rewrite in scope
>
> Reply with "1" / "React", "2" / "Vue", or "3" / "backend-only".

- The front-end framework is **user input, never an analyzer recommendation.** Detect what
  the application uses today, size the rewrite, and accept the named target as given. Never
  compare React and Vue, and never advocate either.
- "Backend-only" is a first-class answer, not a fallback. Plenty of programmes modernize the
  back end and leave the UI untouched. In that case `frontend-to-spa.md` is not loaded at all.

**Once the target is confirmed**, the analyzer's job is to surface risks and manual-effort
items for **that** target — not to educate the user on choosing between targets. Emphasise:
- Items that automated tooling (AWS Transform, Kiro) can handle
- Items that require manual effort or redesign
- Items that are critical blockers requiring upfront remediation
- Risks that must be flagged ahead of time so teams can plan fixes before modernization work begins

### Step 2: Load Steering Files — Authoritative Dispatch Table

**This table is the single authoritative dispatch mechanism for this power.** Every steering
file is `inclusion: manual`; nothing loads implicitly. No steering file is selected by
pattern matching, and no steering file pulls in another by transclusion. If a file is not
named in the row that matches the detected source + target, it is not loaded.

**Every row loads these three first, in this order:**

1. `steering/report-structure.md` — **AUTHORITATIVE** report format standards
2. `steering/evaluation-framework.md` — universal evaluation areas and the derivable-vs-open-question rule
3. `steering/aws-target-services.md` — AWS service mappings

**Then load the path-specific files, in the order given:**

| Source | Target | Then load, in order |
|--------|--------|---------------------|
| .NET Framework | .NET 8 or .NET 10 | `dotnet-to-aws.md` |
| .NET Framework | Java Spring Boot + SPA | `dotnet-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md` ¹ |
| J2EE — IBM WebSphere | Spring Boot | `websphere-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md` ¹ |
| J2EE — Oracle WebLogic | Spring Boot | `weblogic-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md` ¹ |
| J2EE — WildFly / JBoss EAP | Spring Boot | `wildfly-to-springboot.md`, `j2ee-to-springboot-reactive.md`, `frontend-to-spa.md` ¹ |
| Java SE / plain Java | Spring Boot 3.x + Java 17/21 | `java-to-springboot.md`, `frontend-to-spa.md` ¹ |
| COBOL / Mainframe | Java Spring Boot | `cobol-to-java.md`, `frontend-to-spa.md` ¹ |

¹ Load `frontend-to-spa.md` only when the Step 1B front-end answer was React or Vue. Omit it
for backend-only.

**Order within a row matters.** The universal framework establishes the report contract and
the vocabulary; the source+target leaf applies it to the platform; shared modules and
cross-cutting dimensions assume both.

**One orthogonal conditional row**, which applies on top of any source above:

| Condition | Also load |
|-----------|-----------|
| Oracle database detected **and** the user confirms Oracle → PostgreSQL is in scope | `oracle-to-postgresql.md` |

Database migration scope differs by programme and is **never** assumed in either direction.
Detect the database, report its footprint, and state the scope question explicitly. See the
Database Detection section below.

**Real programmes disagree about this, and the analyzer must not flatten the difference.** Two
patterns are both common and both legitimate:

- Some programmes **exclude** database migration deliberately. The application moves, the database
  stays, and the target design deliberately avoids database change so that the application migration
  is the only variable. Recommending an engine change into this scope contradicts the customer's own
  boundary.
- Other programmes treat the database as a **full workstream in its own right**, sized separately,
  often driven by commercial licence elimination.

Ask which applies. Do not infer it from the source platform, from the presence of a commercial
engine, or from what a previous analysis assumed.

`java-to-springboot.md` deliberately does **not** load `j2ee-to-springboot-reactive.md`: the
shared module is about replacing application-server constructs (EJB, JTA, vendor JNDI) that a
plain Tomcat, Jetty or Struts application does not have.

### Step 3: Execute Platform-Specific Analysis

Follow the loaded platform steering file for:
- Technology-specific detection patterns
- Migration strategy bank
- Code transformation examples
- Platform-specific risks and mitigations

## Analysis Methodology

### Exhaustive Analysis Mode

Generate the most detailed, comprehensive report possible. Assume the user demands extreme depth - this is $1M/project consulting-grade work.

### Incremental Codebase Scanning

To avoid context overflow when analyzing large codebases:

**Phase 1: Discovery (Lightweight)**
- First, scan ONLY for solution/project files
- Build a project inventory WITHOUT reading full file contents
- Identify the solution structure and project count

**Phase 2: Targeted Analysis (Per-Project)**
- Analyze ONE project at a time
- In the first pass, gather a map of all files to understand scope
- Read only files relevant to the current analysis step
- Summarize findings before moving to the next project

**Phase 3: Selective Deep Dives**
- Only read full file contents when specifically needed
- Use grep/search tools to FIND patterns first
- Avoid reading entire directories into context

**Memory Management Rules:**
- Summarize findings after each major component
- Do NOT load all source files simultaneously
- Process large codebases in batches of 5-10 files
- Prioritize: config files → project files → key source → supporting files

### Database Detection

Scan the codebase to identify database technology:
- SQL Server indicators: connection strings, `SqlConnection`, `SqlCommand`, `Microsoft.Data.SqlClient`, EF/EF Core SQL Server providers
- Oracle indicators: `Oracle.DataAccess`, `Oracle.ManagedDataAccess`, `ojdbc*.jar`, `oracle.jdbc.*`, `OracleDialect`, `tnsnames.ora`
- DB2 indicators: `IBM.Data.DB2`, `com.ibm.db2.jcc`, `EXEC SQL` against DB2
- PostgreSQL / MySQL / other indicators: driver and dialect declarations

**Database migration scope is never assumed.** Report the footprint — engine, version,
edition, data access technology, and the volume of logic held in the database (stored
procedures, functions, triggers, packages, ETL packages) — and then state the scope question
explicitly as something the customer must confirm:

- Programmes that keep the database deliberately design the target to **avoid database
  change**, and the analysis must respect that. Do not present a database migration the
  customer has excluded as though it were part of the recommended path.
- Programmes that include the database treat it as a **workstream of its own**, sized
  separately from the application migration.

Only when the user confirms migration is in scope should a target engine such as Aurora
PostgreSQL be recommended. For Oracle → PostgreSQL specifically, load
`steering/oracle-to-postgresql.md` per the conditional row in the Step 2 dispatch table.

### Proprietary Dependency Analysis

For EVERY proprietary/commercial library found:
- Detailed compatibility assessment table
- Code migration examples (before/after)
- Specific mitigation options with effort levels

## Bundled MCP Server

This power includes the `fetch` MCP server (configured in `mcp.json`) to query package registry APIs for license verification.

**Note**: Ensure `uvx` is installed (via `uv` Python package manager). See [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/).

## MCP Config Placeholders

**No placeholders needed** — the `mcp.json` configuration works as-is with the standard `mcp-server-fetch` package. The only prerequisite is that `uvx` is installed on the host system.

## Prerequisites

- Access to codebase (local or repository)
- Familiarity with source platform (.NET, WebSphere, WebLogic, WildFly/JBoss EAP, plain Java, or COBOL/Mainframe)
- Understanding of modernization goals (cloud-native, containerization, etc.)
- A decision on the target platform — .NET 8, .NET 10, or Java Spring Boot — and, for a Java target, whether a React or Vue front-end rewrite is in scope
- Awareness of proprietary/commercial library dependencies

## Trigger Phrases

This power activates when users mention:
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

## Output

Generate report in `yymmddhhmm_MODERNIZATION_REPORT.md` following the structure defined in `steering/report-structure.md`. As for yymmddhhmm, it is the current time's year for yy, month for mm, day for dd, hour for hh and minutes for mm (UTC Timezone).

**CRITICAL:** The `steering/report-structure.md` file is the SINGLE SOURCE OF TRUTH for all report formatting, section structure, visualization standards, and quality requirements. Do NOT deviate from it.

## Troubleshooting

### `uvx: command not found`

**Cause:** The `uv` Python package manager is not installed.

**Solution:**
1. Install `uv` via pip: `pip install uv`, or via Homebrew: `brew install uv`
2. Verify: `uvx --version`
3. Restart Kiro so the MCP server picks up the updated PATH
4. For full options, see the [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)

### `fetch` MCP tool times out on package registry lookups

**Cause:** Network restrictions, corporate proxy, or registry rate limiting.

**Solution:**
1. Verify outbound HTTPS access to `api.nuget.org` (NuGet), `search.maven.org` / `repo.maven.apache.org` (Maven) and `registry.npmjs.org` (npm, for front-end dependencies)
2. If behind a proxy, ensure `HTTPS_PROXY` / `HTTP_PROXY` env vars are set in the shell that launched Kiro
3. Retry — the analyzer can continue with manual license verification notes if automated lookup fails

### Report generation runs out of context on large codebases

**Cause:** Attempting to load too many source files simultaneously.

**Solution:** Follow the Incremental Codebase Scanning rules in the Analysis Methodology section above:
1. Phase 1: Discovery only — scan for `.sln`/`.csproj`/`pom.xml`/COBOL source files without reading contents
2. Phase 2: Analyze one project at a time, summarizing before moving on
3. Phase 3: Use grep/search to locate patterns, then read only the matching files
4. Process in batches of 5–10 files; never load an entire directory into context

### Source platform detection is ambiguous (mixed codebase)

**Cause:** Codebase contains markers for multiple source platforms (e.g., legacy .NET alongside Java modules, or two application server vendors).

**Solution:**
1. Ask the user which component is the modernization target
2. If multiple components need analysis, generate separate reports — one per source platform
3. Do NOT attempt to combine platform-specific steering files for two different source platforms in a single analysis pass

### Source detected but the target platform is unclear

**Cause:** The user's initial prompt did not name a target.

**Solution:** Use the mandatory target prompts in Step 1B. Do NOT assume a default. Do NOT proceed until the user confirms the target runtime, and — for a Java target — whether a React or Vue front-end rewrite is in scope or the work is backend-only.

### A steering file that should apply was never loaded

**Cause:** Steering files in this power are all `inclusion: manual`. Nothing loads implicitly, by pattern match, or by transclusion from another steering file.

**Solution:** Re-check the Step 2 dispatch table for the row matching the detected source + target, and load every file that row names, in the order given. If a needed file is absent from that row, the dispatch table is the thing to fix.
