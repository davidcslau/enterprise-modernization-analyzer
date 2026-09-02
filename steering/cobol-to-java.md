---
inclusion: manual
---

# COBOL Mainframe to Java Spring Boot Modernization

## Objective

Migrate IBM Mainframe COBOL applications (CICS online, batch, DB2, VSAM) to Spring Boot 4.1.x on Java 21 or 25, targeting AWS container-based deployments optimized for Graviton processors.

## Platform Detection

### COBOL/Mainframe-Specific Files

- `*.cbl` / `*.cob` - COBOL source programs
- `*.cpy` / `*.CPY` - COBOL copybooks (shared data structures)
- `*.bms` / `*.BMS` - BMS map definitions (CICS screen layouts)
- `*.jcl` / `*.JCL` - Job Control Language (batch scheduling)
- `*.proc` - JCL procedures
- `*.sql` - DB2 SQL DDL and DML scripts
- `*.csd` - CICS resource definitions (CSD)

### COBOL-Specific Code Patterns

- `EXEC CICS` - CICS online transaction processing
- `EXEC SQL` - Embedded DB2 SQL
- `COPY` statements - Copybook inclusions
- `CALL` / `EXEC CICS XCTL` / `EXEC CICS LINK` - Inter-program communication
- `EXEC CICS READ` / `WRITE` / `REWRITE` / `DELETE` - VSAM file I/O
- `EXEC CICS SEND MAP` / `RECEIVE MAP` - BMS screen handling
- `EXEC CICS RETURN TRANSID` - Pseudo-conversational control
- `PERFORM` / `PERFORM UNTIL` / `PERFORM VARYING` - Control flow
- `EVALUATE` / `IF` / `WHEN` - Decision logic
- `STRING` / `UNSTRING` / `INSPECT` - String manipulation
- `SORT` / `MERGE` - Data sorting
- `REDEFINES` - Memory overlay / union types

### COBOL Program Type Classification

| Indicator | Program Type | Migration Target |
|-----------|-------------|-----------------|
| `EXEC CICS SEND MAP` + `RECEIVE MAP` | CICS Online (Screen) | Spring Boot REST Controller + Web UI |
| `EXEC CICS READ/WRITE` only | CICS Online (Data) | Spring Boot @Service + JPA Repository |
| `EXEC SQL` + no CICS | Batch DB2 | Spring Batch Job + JPA/JDBC |
| JCL with SORT/MERGE utilities | Batch File Processing | Spring Batch Job + FlatFileItemReader |
| `CALL` subroutines only | Utility/Library | Spring @Component / @Service |
| `EXEC CICS XCTL` routing | Menu/Navigation | Spring Boot Controller routing |


## COBOL Modernization Decision Tree

```mermaid
flowchart TD
    Start([Start: COBOL Mainframe Application])
    CheckCICS{Uses CICS Online?}
    CheckDB2{Uses DB2 Database?}
    CheckVSAM{Uses VSAM Files?}
    CheckBatch{Has JCL Batch Jobs?}
    CheckComplexity{Business Logic Complexity?}
    CICSPath[CICS to Spring Boot REST APIs]
    DB2Path[DB2 to Aurora PostgreSQL via SCT/DMS]
    VSAMPath[VSAM to Aurora PostgreSQL Tables]
    BatchPath[JCL/Batch to Spring Batch Jobs]
    SimplePath[Simple Refactor: Direct Translation]
    ComplexPath[Complex Refactor: Decompose to Microservices]
    TargetArch([Target: Spring Boot 4.1.x + Java 21/25 on ECS Fargate / Graviton])

    Start --> CheckCICS
    CheckCICS -- Yes --> CICSPath
    CheckCICS -- No --> CheckBatch
    CheckBatch -- Yes --> BatchPath
    CheckBatch -- No --> SimplePath
    CICSPath --> CheckDB2
    BatchPath --> CheckDB2
    CheckDB2 -- Yes --> DB2Path
    CheckDB2 -- No --> CheckVSAM
    DB2Path --> CheckVSAM
    CheckVSAM -- Yes --> VSAMPath
    CheckVSAM -- No --> CheckComplexity
    VSAMPath --> CheckComplexity
    CheckComplexity -- High --> ComplexPath
    CheckComplexity -- Low/Medium --> SimplePath
    ComplexPath --> TargetArch
    SimplePath --> TargetArch

    classDef decision fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef process fill:#fff9c4,stroke:#fbc02d,stroke-width:2px;
    classDef success fill:#e8f5e9,stroke:#2e7d32,stroke-width:4px;
    classDef termination fill:#f9f9f9,stroke:#333,stroke-width:2px;
    class Start,TargetArch termination;
    class CheckCICS,CheckDB2,CheckVSAM,CheckBatch,CheckComplexity decision;
    class CICSPath,DB2Path,VSAMPath,BatchPath,SimplePath,ComplexPath process;
```

### Decision Tree Mapping Instructions

When generating the modernization report, include a Decision Tree Findings Map:

| Decision Node | What We Scanned | What We Found | Result |
|---------------|-----------------|---------------|--------|
| Uses CICS Online? | `EXEC CICS` commands in .cbl files | _(e.g., "15 CICS programs with SEND/RECEIVE MAP")_ | Yes/No |
| Uses DB2 Database? | `EXEC SQL` statements, SQL DDL files | _(e.g., "8 programs with embedded SQL, 12 tables")_ | Yes/No |
| Uses VSAM Files? | `EXEC CICS READ/WRITE`, VSAM DD statements | _(e.g., "5 VSAM KSDS files identified")_ | Yes/No |
| Has JCL Batch Jobs? | .jcl files, SORT/MERGE utilities | _(e.g., "20 JCL jobs with 45 steps")_ | Yes/No |
| Business Logic Complexity? | Cyclomatic complexity, inter-program calls | _(e.g., "High: 50+ programs, deep call chains")_ | Low/Medium/High |


## Migration Strategy Bank

### Data Type Mapping: COBOL to Java

| COBOL Type | PIC Clause | Java Type | Notes |
|------------|-----------|-----------|-------|
| Alphanumeric | `PIC X(n)` | `String` | Trim trailing spaces |
| Numeric Display (small) | `PIC 9(1-4)` | `int` | Or `short` for optimization |
| Numeric Display (medium) | `PIC 9(5-9)` | `int` | Standard integer |
| Numeric Display (large) | `PIC 9(10-18)` | `long` | Long integer |
| Signed Binary | `PIC S9(1-9) COMP` | `int` | Binary/COMP/COMP-4 |
| Signed Binary (large) | `PIC S9(10-18) COMP` | `long` | Binary/COMP/COMP-4 |
| Packed Decimal | `PIC S9(n)V9(m) COMP-3` | `BigDecimal` | Critical for financial data |
| Implied Decimal | `PIC 9(n)V9(m)` | `BigDecimal` | Explicit decimal in Java |
| Single Float | `COMP-1` | `float` | Rarely used in business |
| Double Float | `COMP-2` | `double` | Avoid for financial calcs |
| Condition Name | `88 level` | `enum` or `boolean` | Map to Java enums |
| Group Item | `01`/`05` levels | POJO/DTO class | Nested structure to class |
| REDEFINES | Memory overlay | Inheritance/Composition | Analyze actual usage |
| OCCURS | Array/table | `List<T>` or `T[]` | With optional DEPENDING ON |

### Program Structure Mapping

| COBOL Construct | Java/Spring Boot Equivalent |
|----------------|---------------------------|
| COBOL Program (.cbl) | Java Class (`@Service` or `@Component`) |
| Paragraph | Java method (camelCase naming) |
| Section | Java class or package grouping |
| WORKING-STORAGE | Instance variables / local variables |
| LINKAGE SECTION | Method parameters / DTOs |
| Copybook (.cpy) | Shared Java class (POJO/DTO) in common package |
| PERFORM paragraph | Method invocation |
| PERFORM UNTIL | `while` / `do-while` loop |
| PERFORM VARYING | `for` loop |
| CALL program | Spring DI + method call on injected service |
| XCTL (transfer control) | Delegate to service, return result |
| EVALUATE / WHEN | `switch` expression (Java 17+) or `if-else` |
| STRING | `StringBuilder.append()` |
| UNSTRING | `String.split()` / regex |
| INSPECT TALLYING | String counting methods |
| INSPECT REPLACING | `String.replace()` / `String.replaceAll()` |
| SORT | `Collections.sort()` / `Stream.sorted()` / SQL `ORDER BY` |
| MOVE | Variable assignment |
| COMPUTE | Arithmetic expression |


### CICS to Spring Boot Web

| CICS Construct | Spring Boot Equivalent |
|---------------|----------------------|
| CICS Transaction (TRANSID) | REST API endpoint (`@RestController`) |
| BMS Map (SEND MAP) | JSON response / HTML template |
| BMS Map (RECEIVE MAP) | `@RequestBody` / `@RequestParam` |
| EXEC CICS READ | JPA `findById()` / Spring Data query |
| EXEC CICS WRITE | JPA `save()` (insert) |
| EXEC CICS REWRITE | JPA `save()` (update) |
| EXEC CICS DELETE | JPA `deleteById()` |
| EXEC CICS STARTBR / READNEXT | JPA paginated query / `findAll(Pageable)` |
| EIBAID (PF keys) | HTTP methods (GET/POST/PUT/DELETE) or action params |
| COMMAREA | DTO / Spring Session / Redis |
| EXEC CICS RETURN TRANSID | Stateless REST (no pseudo-conversational needed) |
| EXEC CICS XCTL | Controller redirect / service delegation |
| EXEC CICS LINK | Service method call (synchronous) |
| RESP / RESP2 codes | Java exceptions + `@ExceptionHandler` |
| DFHCOMMAREA | Request/Response DTO |
| CICS Temporary Storage | Redis / ElastiCache |
| CICS Transient Data | Amazon SQS queue |

#### BMS Maps and 3270 Screens → SPA Views

Where a front-end rewrite is in scope, `steering/frontend-to-spa.md` carries the detailed BMS mapping
treatment and is dispatched alongside this file by POWER.md Step 2. It covers the full
`DFHMSD` / `DFHMDI` / `DFHMDF` construct mapping, the field and attribute model (`POS`, `LENGTH`,
`ATTRB`, `PICIN`/`PICOUT`, `COLOR`, `MDT`), the screen flow graph, PF-key conventions, and the
pseudo-conversational state model.

Apply it rather than improvising a screen mapping here. Two points from it are worth repeating because
they bear directly on the business rule extraction in this file:

- **BMS gives you the field model, not the rules.** Attributes yield the terminal-enforced
  constraints (numeric-only, length, protected). The substantive validation lives in the
  `PROCEDURE DIVISION` and must come from the Category 1 extraction below.
- **Numeric field semantics are a correctness risk.** Implied decimals (`PIC 9(5)V99`), signed
  overpunch and `COMP-3` packed fields display differently from how they are stored. Carrying these
  across incorrectly produces silently wrong values in the new UI.

Where the user selected **backend-only** in POWER.md Step 1B, `frontend-to-spa.md` is not loaded and
the target is an API surface with no UI rewrite in scope. In that case, report the BMS map inventory
as part of the interface inventory and note that screen replacement is out of scope.

### Data Access Migration

| COBOL/Mainframe Data | Java/AWS Target | Migration Approach |
|---------------------|----------------|-------------------|
| VSAM KSDS | Aurora PostgreSQL table (PK) | Record layout to JPA @Entity; key to PK |
| VSAM ESDS | Aurora PostgreSQL table (auto-ID) | Sequential to auto-increment ID |
| VSAM RRDS | Aurora PostgreSQL table (int PK) | Relative record to integer PK |
| DB2 Tables | Aurora PostgreSQL | AWS SCT for schema, DMS for data |
| DB2 Stored Procedures | JPA Repository methods / native SQL | Rewrite in Java or PostgreSQL functions |
| DB2 SQLCA | Spring exception handling | Map SQLCODE to Java exceptions |
| Sequential Files | S3 objects / Spring Batch flat files | FlatFileItemReader/Writer |
| GDG (Generation Data Groups) | S3 versioned objects | S3 versioning or timestamped keys |
| EBCDIC encoding | UTF-8 | Charset conversion (CP037 to UTF-8) |

### Batch Processing Migration

| JCL/COBOL Batch | Spring Batch / AWS Equivalent |
|----------------|------------------------------|
| JCL Job | Spring Batch `Job` |
| JCL Job Step | Spring Batch `Step` |
| JCL COND parameter | Spring Batch flow decisions (`on()`/`to()`) |
| JCL DD statement | Spring resource config (`application.yml`) |
| JCL SORT utility | SQL `ORDER BY` / Java `Collections.sort()` |
| JCL IEBGENER (copy) | Spring Batch copy step / S3 copy |
| JCL IDCAMS (VSAM utility) | Database DDL / Flyway migrations |
| Checkpoint/Restart | Spring Batch chunk processing + restart |
| COBOL Report Writer | JasperReports / Apache POI |
| CA-7 / TWS Scheduling | AWS Step Functions / EventBridge Scheduler |
| ABEND handling | Spring Batch `SkipPolicy` / `RetryPolicy` |

### Security Migration

| Mainframe Security | Spring Boot / AWS Equivalent |
|-------------------|----------------------------|
| RACF | Spring Security + AWS Cognito |
| ACF2 | Spring Security + AWS Cognito |
| Top Secret | Spring Security + AWS Cognito |
| CICS Security (CESN) | Spring Security authentication |
| User ID / Password | Cognito User Pools / OAuth 2.0 |
| Security Groups/Roles | Spring `@PreAuthorize` / Cognito Groups |
| Resource-level security | Spring method security / IAM policies |
| Audit logging | CloudWatch Logs / CloudTrail |


## Hybrid Modernization: EC2 Legacy Sidecar Pattern

In some cases, certain mainframe components cannot be directly migrated to Java. This includes proprietary middleware, hardware-specific interfaces, or third-party mainframe software with no Java equivalent.

```mermaid
flowchart LR
    subgraph Modern["Modernized Stack (ECS/EKS)"]
        App["Spring Boot 4.1.x App<br/>(Java 21/25 on Linux Container)"]
    end
    subgraph Legacy["Legacy Sidecar (EC2 / M2 Replatform)"]
        Wrapper["API Wrapper<br/>(REST/gRPC)"]
        Component["Un-modernizable<br/>Component<br/>(e.g., Proprietary Middleware,<br/>Hardware Interfaces)"]
        Wrapper --> Component
    end
    App -- "API Call" --> Wrapper
```

When this pattern applies, include in the report:
- List of specific components requiring the legacy sidecar
- Justification for why each component cannot be modernized
- API wrapper design recommendations
- Cost implications of maintaining the EC2/M2 sidecar
- Long-term plan to retire the sidecar

## COBOL-Specific Risks

### Proprietary Dependencies

| Risk | Mitigation |
|------|------------|
| CICS pseudo-conversational model | Replace with stateless REST APIs |
| BMS screen maps | Replace with modern web UI or API-only |
| VSAM file access patterns | Migrate to relational database with JPA |
| DB2 embedded SQL (EXEC SQL) | Convert to Spring Data JPA / native PostgreSQL |
| JCL job scheduling dependencies | Map to Spring Batch + Step Functions |
| EBCDIC character encoding | Convert all data to UTF-8 during migration |
| Packed decimal (COMP-3) precision | Use `BigDecimal` exclusively for financial data |
| COBOL REDEFINES (memory overlays) | Redesign as Java inheritance/composition |
| Mainframe security (RACF/ACF2) | Replace with Spring Security + Cognito |
| Inter-program COMMAREA coupling | Redesign as service interfaces with DTOs |

### Data Migration Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| EBCDIC to UTF-8 data corruption | Data integrity loss | Use validated charset conversion with CP037 codepage |
| Packed decimal precision loss | Financial calculation errors | Map all COMP-3 to BigDecimal, never float/double |
| VSAM key structure mismatch | Query performance degradation | Analyze key patterns, create proper indexes |
| DB2-specific SQL syntax | Query failures on PostgreSQL | Use AWS SCT for automated conversion |
| Implicit decimal points (PIC V) | Calculation errors | Make all decimals explicit in Java |
| REDEFINES data interpretation | Data corruption | Analyze actual usage, create proper Java types |
| GDG versioning semantics | Data loss | Map to S3 versioning or timestamped naming |


## Implementation Phases

### Phase 0: Discovery and Assessment
1. Inventory all COBOL programs, copybooks, JCL jobs, BMS maps
2. Classify programs by type (CICS online, batch, utility, subroutine)
3. Map inter-program dependencies (CALL, XCTL, LINK chains)
4. Identify VSAM files, DB2 tables, and data access patterns
5. Extract and document all business rules (see Business Logic Extraction Framework)
6. Calculate complexity metrics (LOC, cyclomatic complexity, dependency depth)
7. Identify dead code and unused programs for elimination

### Phase 1: Foundation and Infrastructure
1. Set up Spring Boot 4.1.x project structure with Java 21 or 25
2. Configure Aurora PostgreSQL database
3. Set up Spring Security with AWS Cognito
4. Create CI/CD pipeline (CodePipeline, CodeBuild)
5. Configure container infrastructure (ECS Fargate, Graviton)
6. Set up Spring Batch infrastructure for batch jobs
7. Create shared DTO/POJO classes from copybooks

### Phase 2: Data Migration
1. Convert VSAM record layouts to JPA entity classes
2. Generate PostgreSQL schema from VSAM/DB2 structures
3. Use AWS SCT for DB2 to PostgreSQL schema conversion
4. Use AWS DMS for data migration with minimal downtime
5. Convert EBCDIC data to UTF-8
6. Validate data integrity post-migration
7. Create Flyway migration scripts for schema versioning

### Phase 3: CICS Online Program Migration
1. Convert BMS maps to REST API endpoint definitions
2. Migrate CICS transaction programs to Spring Boot controllers
3. Convert CICS file I/O to JPA repository operations
4. Replace COMMAREA with DTOs and service interfaces
5. Implement Spring Security for authentication/authorization
6. Replace pseudo-conversational model with stateless REST

### Phase 4: Batch Job Migration
1. Convert JCL jobs to Spring Batch job definitions
2. Migrate batch COBOL programs to Spring Batch steps
3. Replace JCL SORT/MERGE with Java/SQL equivalents
4. Configure Spring Batch chunk processing for checkpoint/restart
5. Set up AWS Step Functions for job orchestration
6. Configure EventBridge for scheduling

### Phase 5: Integration and Testing
1. Integration testing of all migrated services
2. Data validation (compare mainframe output vs Java output)
3. Performance testing and optimization
4. Security testing and penetration testing
5. User acceptance testing
6. Parallel run: mainframe and Java side-by-side

### Phase 6: Cutover and Decommission
1. Production deployment to ECS Fargate
2. DNS/routing cutover
3. Monitor and stabilize
4. Decommission mainframe resources
5. Knowledge transfer and documentation


## Code Migration Examples

### COBOL Copybook to Java Entity

**Before (COBOL Copybook):**
```cobol
       01  SEC-USER-DATA.
           05  SEC-USR-ID            PIC X(08).
           05  SEC-USR-FNAME         PIC X(20).
           05  SEC-USR-LNAME         PIC X(20).
           05  SEC-USR-PWD           PIC X(08).
           05  SEC-USR-TYPE          PIC X(01).
           05  SEC-USR-FILLER        PIC X(23).
```

**After (Java JPA Entity):**
```java
@Entity
@Table(name = "sec_user")
public class SecUser {
    @Id
    @Column(name = "usr_id", length = 8)
    private String userId;

    @Column(name = "usr_fname", length = 20)
    private String firstName;

    @Column(name = "usr_lname", length = 20)
    private String lastName;

    @Column(name = "usr_pwd", length = 8)
    private String password;

    @Column(name = "usr_type", length = 1)
    private String userType;
}
```

### CICS Transaction to REST Controller

**Before (COBOL CICS Sign-on):**
```cobol
       VALIDATE-USER.
           EXEC CICS READ FILE('USRSEC')
                INTO(SEC-USER-DATA)
                RIDFLD(WS-USER-ID)
                RESP(WS-RESP-CD)
           END-EXEC.
           IF WS-RESP-CD = DFHRESP(NORMAL)
               IF SEC-USR-PWD = WS-PASSWORD
                   PERFORM ROUTE-USER
               ELSE
                   MOVE 'Invalid password' TO WS-MESSAGE
               END-IF
           ELSE
               MOVE 'User not found' TO WS-MESSAGE
           END-IF.
```

**After (Spring Boot):**
```java
@RestController
@RequestMapping("/api/auth")
public class SignOnController {
    private final AuthenticationService authService;

    public SignOnController(AuthenticationService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(
            authService.authenticate(request.getUserId(), request.getPassword()));
    }
}
```

### JCL Batch Job to Spring Batch

**Before (JCL):**
```jcl
//DAILYRPT JOB (ACCT),'DAILY REPORT',CLASS=A
//STEP01   EXEC PGM=RPTPGM
//INPUT    DD DSN=PROD.TRANS.DAILY,DISP=SHR
//OUTPUT   DD DSN=PROD.REPORT.DAILY,DISP=(NEW,CATLG)
```

**After (Spring Batch):**
```java
@Configuration
public class DailyReportJobConfig {
    @Bean
    public Job dailyReportJob(JobRepository jobRepository, Step processStep) {
        return new JobBuilder("dailyReportJob", jobRepository)
            .start(processStep).build();
    }

    @Bean
    public Step processStep(JobRepository repo, PlatformTransactionManager tx) {
        return new StepBuilder("processTransactions", repo)
            .<Transaction, ReportLine>chunk(100, tx)
            .reader(transactionReader())
            .processor(reportProcessor())
            .writer(reportWriter())
            .build();
    }
}
```


## AWS Target Architecture

```mermaid
graph TB
    subgraph "Current State: Mainframe"
        MF[IBM Mainframe z/OS]
        CICS[CICS Transaction Server]
        COBOL[COBOL Programs]
        DB2[(DB2 Database)]
        VSAM[(VSAM Files)]
        JCL[JCL Batch Jobs]
        RACF[RACF Security]
        BMS[BMS Screens]
    end

    subgraph "Target State: AWS"
        ECS[Amazon ECS Fargate / Graviton]
        SB[Spring Boot 4.1.x / Java 21-25]
        RDS[(Amazon Aurora PostgreSQL)]
        BATCH[Spring Batch on ECS]
        SF[AWS Step Functions]
        COG[Amazon Cognito]
        S3[(Amazon S3)]
        SQS[Amazon SQS]
        CW[Amazon CloudWatch]
        ALB[Application Load Balancer]
    end

    MF --> ECS
    CICS --> SB
    COBOL --> SB
    DB2 --> RDS
    VSAM --> RDS
    JCL --> BATCH
    JCL --> SF
    RACF --> COG
    BMS --> ALB

    style MF fill:#ff6b6b
    style CICS fill:#ff6b6b
    style COBOL fill:#ff6b6b
    style DB2 fill:#ffa94d
    style VSAM fill:#ffa94d
    style JCL fill:#ff6b6b
    style RACF fill:#ffa94d
    style BMS fill:#ff6b6b
    style ECS fill:#69db7c
    style SB fill:#69db7c
    style RDS fill:#74c0fc
    style BATCH fill:#69db7c
    style SF fill:#74c0fc
    style COG fill:#74c0fc
    style S3 fill:#74c0fc
    style SQS fill:#74c0fc
    style CW fill:#74c0fc
    style ALB fill:#74c0fc
```

## Validation Criteria

1. Zero COBOL/CICS/JCL dependencies in final Java build
2. All VSAM data migrated to Aurora PostgreSQL with integrity verified
3. All DB2 data migrated to Aurora PostgreSQL via SCT + DMS
4. All CICS transactions converted to REST API endpoints
5. All batch jobs converted to Spring Batch with Step Functions orchestration
6. Spring Security + Cognito replaces RACF/ACF2 authentication
7. All financial calculations use `BigDecimal` (never float/double)
8. All data converted from EBCDIC to UTF-8
9. Container runs on both x86_64 and ARM64 (Graviton)
10. Comprehensive test coverage: unit, integration, regression, performance
11. Parallel run validation: mainframe output matches Java output

## Recommended Tools

| Tool | Purpose | Priority |
|------|---------|----------|
| AWS Transform for Mainframe | End-to-end COBOL to Java refactoring with AI agents | 1st |
| AWS Mainframe Modernization (Blu Age) | Automated COBOL to Java code transformation | 2nd |
| AWS Mainframe Modernization (Micro Focus / Rocket) | Replatform: run COBOL on AWS without rewriting | Alternative |
| AWS Schema Conversion Tool (SCT) | DB2 to PostgreSQL schema conversion | For DB migration |
| AWS Database Migration Service (DMS) | Data migration with minimal downtime | For DB migration |
| Kiro | AI-assisted code migration, refactoring, test generation | Throughout all phases |
| Spring Batch | Batch job framework replacing JCL/COBOL batch | Core framework |
| AWS Step Functions | Batch job orchestration replacing mainframe schedulers | Orchestration |
| Amazon EventBridge Scheduler | Cron-based job scheduling replacing CA-7/TWS | Scheduling |

**Tool Selection Guidance:**
- For full AI-driven refactoring (COBOL to Java): Use AWS Transform for Mainframe
- For automated code transformation: Use AWS Mainframe Modernization (Blu Age)
- For replatforming without rewrite: Use AWS Mainframe Modernization (Micro Focus/Rocket)
- For database migration (DB2 to Aurora PostgreSQL): Use SCT + DMS
- For incremental migration with AI assistance: Use Kiro throughout


## Required Mainframe Analysis Depth

The universal Mandatory Baseline Inventory in `evaluation-framework.md` applies to this path too, but
several of its items have mainframe-specific equivalents. Map them as follows — these are the
mainframe answers to the same questions asked on every other path.

### M1. COBOL Dialect and Compiler (maps to B1, runtime version and vendor)

Reporting "COBOL" is not sufficient. The dialect and compiler determine which language features are
available, how arithmetic and collation behave, and what a target Java implementation must reproduce.

| What to establish | Detection signals |
|-------------------|-------------------|
| **Compiler and version** | `PROCESS`/`CBL` statement options in source, compile JCL `PARM=` options, `//SYSIN` compiler steps, listing headers, build procedure members |
| **IBM Enterprise COBOL** (and version) | `PROCESS` options such as `ARITH(EXTEND)`, `TRUNC(BIN)`, `DYNAM`, `NUMPROC`; IBM-specific intrinsic functions |
| **IBM COBOL II / OS/VS COBOL** (pre-Enterprise) | `GOBACK` conventions, absence of Enterprise-only constructs, very old copybook idiom. Signals an older codebase with more constrained language features |
| **Micro Focus COBOL** | Micro Focus directives, `$SET` statements, non-IBM file handling syntax |
| **GnuCOBOL** | `>>SOURCE` directives, GnuCOBOL-specific extensions |
| **Dialect-specific extensions in use** | Vendor intrinsic functions, non-standard `EXEC` statements, vendor-specific file organisations |

**Compiler options are behaviour, not build trivia.** `TRUNC(BIN)` versus `TRUNC(STD)` changes binary
field truncation, `ARITH(EXTEND)` changes decimal precision limits, and `NUMPROC(PFD)` changes how
invalid numeric data is handled. Report the options found, because a Java reimplementation must match
the arithmetic the current system actually performs. This connects to the Platform-Specific Compiler
Behavior section below.

### M2. CICS Coupling Depth (maps to B4 and B10, where logic lives and where the seams are)

Establish **how deeply** the business logic is entangled with CICS, not merely whether CICS is
present. This determines how much of each program is reusable logic versus transaction-monitor
plumbing.

| Coupling level | Indicators | Consequence |
|----------------|-----------|-------------|
| **Deeply coupled** | `EXEC CICS` statements interleaved throughout the `PROCEDURE DIVISION`; business rules inside screen-handling paragraphs; `EIBAID` / `EIBCALEN` checks driving business decisions; COMMAREA layout carrying domain state | Logic must be separated from transaction handling before it can be reimplemented. The extraction workstream is large |
| **Moderately coupled** | CICS confined to identifiable send/receive and file paragraphs, with `PERFORM`ed logic paragraphs that are largely CICS-free | Clear seams exist. Logic paragraphs translate more directly |
| **Lightly coupled** | Business logic in separate `CALL`ed subprograms with no CICS statements, driven by a thin CICS shell | The best case. The subprograms are close to portable logic already |
| **Batch-only (no CICS)** | No `EXEC CICS` anywhere | Different profile entirely — see M4 |

Quantify it: count `EXEC CICS` statements, the programs containing them, and the ratio of CICS
statements to total procedural statements per program. Identify programs that are **pure logic**
(no CICS, no SQL, no file I/O) — those are the cleanest migration candidates and the natural first
targets.

Also establish:
- **Pseudo-conversational state**: what the COMMAREA and CICS Temporary Storage carry between screens. This is the mainframe session state, and it maps onto B8
- **`XCTL` / `LINK` chains**: the call graph, and how deep it goes. Long chains mean transaction boundaries that are not obvious from any single program
- **Transaction definitions**: `.csd` entries linking TRANSID to program and mapset

### M3. DB2 vs VSAM Split (maps to B7, data access technology)

Report the split explicitly with counts, because the two carry very different migration
characteristics and most estates have both.

| Data store | Detection | Migration character |
|------------|-----------|---------------------|
| **DB2** | `EXEC SQL` blocks, `DCLGEN` copybooks, `SQLCA`, `INCLUDE SQLCA`, DBRM/bind JCL, plan and package names | **The more tractable half.** Relational structure already exists, SQL is largely portable, and referential integrity is declared. Conversion targets a relational engine |
| **VSAM (KSDS)** | `ORGANIZATION INDEXED`, `RECORD KEY`, `SELECT ... ASSIGN TO`, IDCAMS `DEFINE CLUSTER` | **The harder half.** No schema beyond the copybook, keys and access paths implied by code, and no referential integrity. The relational model must be *designed* from the copybook and the access patterns |
| **VSAM (ESDS / RRDS)** | `ORGANIZATION SEQUENTIAL` / `RELATIVE`, relative record access | Harder again — record position may itself be meaningful |
| **Flat / sequential (QSAM)** | `ORGANIZATION SEQUENTIAL`, GDG references in JCL | Often interchange files rather than a data store. Frequently become S3 objects |
| **IMS DB** | `DL/I` calls, `CBLTDLI`, PSB/DBD references | Hierarchical model requiring redesign to relational |

Quantify: number of DB2 tables referenced, number of VSAM files, and which programs touch which. Then
report the **proportion of business data** in each. An estate that is 90% DB2 is a materially different
data migration from one that is 90% VSAM, and averaging the two hides the risk.

Additionally flag:
- **Copybooks as the only schema** for VSAM files — and any file whose copybook has `REDEFINES`, meaning one physical record carries several logical layouts distinguished by a type field. These need untangling before a relational design is possible
- **Files shared between programs** with different copybook views of the same record — a strong signal of drift
- **`COMP-3` packed decimal and signed overpunch fields**, which need explicit conversion rules
- **Date representations**: 6-digit dates, Julian dates, and any windowing logic for two-digit years

Database migration scope for this path follows the same rule as every other: report the footprint and
state the scope question. Mainframe data migration is nearly always in scope because the platform
itself is being left, but confirm rather than assume, and note where a customer intends to keep DB2
running (for example on a co-existence timeline) as that changes the target design.

### M4. JCL and Scheduler Coupling (maps to B12, deployment artifact, and B9, integrations)

Batch orchestration lives outside the COBOL source, so it is easy to under-report and then discover
late. Inventory it as a first-class part of the application.

| What to establish | Detection signals |
|-------------------|-------------------|
| **JCL job inventory** | `.jcl` members, `//JOB` cards, PROC and INCLUDE members |
| **Job step structure** | `//EXEC PGM=`, `//EXEC PROC=`, step dependencies, `COND=` and `IF/THEN/ELSE` conditional execution |
| **Dataset flow between steps** | `//DD` statements, temporary datasets (`&&TEMP`), GDG generations (`(+1)`, `(0)`, `(-1)`) |
| **Utility usage** | `IDCAMS`, `SORT`/`DFSORT`/`SYNCSORT`, `IEBGENER`, `IEFBR14`, `IKJEFT01` — these do real work and each needs a target |
| **Scheduler** | **Control-M**, CA-7, TWS/IWS/OPC, Zeke, Zena, or JCL-internal chaining. Look for scheduler control statements, job naming conventions and calendar references |
| **Schedule semantics** | Run calendars, dependencies between jobs, restart and rerun procedures, checkpoint/restart logic |
| **Cross-system dependencies** | Jobs triggered by or triggering other applications; file arrival triggers; FTP/NDM (Connect:Direct) transfers |

**Report the scheduler explicitly.** The dependency graph held in Control-M or CA-7 **is** the batch
architecture, and it is not visible in the COBOL or the JCL alone. Its absence from the analysis is a
gap worth naming: state what could be determined from JCL, and flag the scheduler definitions as
required customer input where they are not available in the repository.

Targets: `SORT` steps become Spring Batch processing or database ordering; GDG generations become
versioned S3 objects; scheduler dependencies become Step Functions, EventBridge Scheduler or Spring
Batch job orchestration. **Restart and rerun semantics deserve specific attention** — mainframe batch
has mature checkpoint/restart behaviour that operations teams rely on, and it does not appear by
default in a reimplementation.

### M5. Security and Authorization (maps to B6, auth mechanism and blast radius)

The mainframe auth finding is the external security manager, already mapped in the Security Migration
table above. Establish additionally:

- **Which manager**: RACF, ACF2 or Top Secret, and whether authorization is by user, group or resource profile
- **CICS transaction-level security**: which TRANSIDs are protected, and by what
- **Resource-level rules**: dataset profiles, DB2 grants, file-level protections — authorization enforced *outside* the application code, which means it is invisible to a source scan and must be requested
- **In-program authorization**: user ID or group checks inside the `PROCEDURE DIVISION`. These **are** visible in source and belong in the Category 9 extraction
- **Blast radius**: how many transactions and jobs depend on the same security definitions, and whether other applications share them

**State plainly that external security manager definitions cannot be derived from source code.**
Report the in-program checks that are visible, and name the external rules as required customer
input — this is exactly the derivable-vs-customer-input split from `evaluation-framework.md`.

### M6. Baseline Buildability (maps to B2, build tooling and buildability)

The mainframe equivalent of "does it build from a clean checkout":

- Is the **compile and link JCL** available, along with every PROC and INCLUDE member it references?
- Are **all copybooks** present, including those referenced indirectly? A missing copybook makes a program uncompilable and its record layouts unknowable
- Are **DB2 bind and DBRM** steps available for programs with embedded SQL?
- Is there a **repeatable build** at all, or is compilation a manual per-member activity?
- Can the application be compiled **outside production** today?

A codebase that cannot be compiled, or whose copybooks are incomplete, is a **gating finding** in the
same sense as a non-building baseline on any other path: behavioural equivalence cannot be established
against something that cannot be built or run.

## COBOL-Specific Evaluation Areas (Beyond Standard Framework)

The standard evaluation framework (evaluation-framework.md) covers universal areas. The following are COBOL/mainframe-specific evaluation areas that MUST be assessed in addition to provide modernization specialists with the evidence they need to plan effectively.

### Reverse Engineering Readiness

Successful COBOL modernization has two halves: reverse engineering (understanding what exists) and forward engineering (building the new system). Thorough reverse engineering is the foundation for a well-planned modernization. Assess:

- Are all COBOL programs, copybooks, JCL jobs, and BMS maps inventoried?
- Are inter-program dependencies (CALL, XCTL, LINK chains) fully mapped?
- Are all implicit dependencies (copybooks, shared files, JCL orchestration) resolved?
- Is there a deterministic model of the application landscape?
- Has dead code been identified for elimination (typically 20-40% of codebase)?

### Platform-Specific Compiler Behavior

The same COBOL source code behaves differently depending on the compiler and runtime. These behaviors are NOT in the source code and must be documented for modernization specialists:

| Behavior | Consideration | Specialist Guidance |
|----------|--------------|-------------------|
| Number rounding rules | Financial calculation accuracy depends on compiler-specific rounding | Document compiler-specific rounding; replicate in Java |
| EBCDIC collating sequence | Sort/comparison logic may produce different results in ASCII/UTF-8 | Test all comparison and sort logic explicitly |
| Memory layout (COMP, COMP-3) | Data interpretation depends on platform-specific storage format | Map all data types precisely to Java equivalents |
| Packed decimal handling | Precision in financial data requires exact mapping | Use BigDecimal exclusively; validate at boundary values |
| REDEFINES memory overlays | Multiple interpretations of same memory area | Analyze actual usage patterns; create proper Java types |

### Undocumented Business Rules (Tribal Knowledge)

Business logic embedded in COBOL programs is often the most valuable asset in the system. Modernization specialists need a clear picture of how well this logic is documented:

- Are subject matter experts (SMEs) available who understand the business rules?
- Can business rules be extracted and validated before migration?
- Is there a business rule traceability matrix?
- What percentage of business logic is documented vs undocumented?
- Are there retired or soon-to-retire staff whose knowledge should be captured?

### Regulatory Compliance Considerations

Modernization specialists need to understand the compliance landscape to plan the migration approach:

| Regulation | Consideration | What Specialists Need |
|------------|--------------|---------------------|
| SOX (Sarbanes-Oxley) | Audit trails, access controls, change management | Current audit logging patterns and how to preserve them |
| PCI DSS | Encryption, monitoring, vulnerability management | Payment data flows and current security controls |
| GDPR / Privacy | Data sovereignty, PII protection | PII field inventory and data residency requirements |
| HIPAA | PHI protection, access controls | PHI data flows and encryption requirements |
| Industry-specific | Banking (GLBA), Insurance, Government (FISMA) | Current compliance control mappings |

### Performance and Operational Baseline

Establishing the current performance baseline gives modernization specialists the targets they need to design the right architecture:

| Metric | What to Capture | Why It Matters |
|--------|----------------|---------------|
| Transaction latency | Current response times for key transactions | Sets the performance target for the Java system |
| Transaction throughput | Peak and average TPS | Determines infrastructure sizing |
| Batch window | Current batch completion times and deadlines | Defines parallelization requirements for Spring Batch |
| Checkpoint/restart | Current restart granularity | Determines Spring Batch chunk sizing |
| Availability SLA | Current uptime requirements | Drives multi-AZ and DR architecture decisions |

### Coexistence and Migration Strategy Considerations

For large mainframe portfolios, modernization specialists will need to design a coexistence architecture. Provide evidence on:

- Can the application be decomposed into independently migratable modules?
- What downstream systems consume mainframe data (file feeds, MQ, APIs)?
- What upstream systems feed data into the mainframe?
- What integration patterns exist (CICS Transaction Gateway, MQ, ESB, file transfers)?
- Is there a natural decomposition boundary for incremental migration?

```mermaid
flowchart LR
    subgraph Facade["API Gateway / Facade"]
        Router[Request Router]
    end
    subgraph Legacy["Mainframe (Shrinking)"]
        COBOL[COBOL Programs]
        VSAM[(VSAM/DB2)]
    end
    subgraph Modern["AWS (Growing)"]
        Java[Spring Boot Services]
        Aurora[(Aurora PostgreSQL)]
    end
    subgraph Sync["Data Sync"]
        CDC[CDC / DMS]
    end

    Router -- "Legacy Routes" --> COBOL
    Router -- "Migrated Routes" --> Java
    VSAM <-- "Sync" --> CDC
    CDC <-- "Sync" --> Aurora

    style Legacy fill:#ffa94d
    style Modern fill:#69db7c
    style Facade fill:#74c0fc
    style Sync fill:#ffd43b
```


### Mainframe Cost Baseline

Establishing the current cost baseline enables modernization specialists to build accurate ROI models:

| Cost Component | Description | Typical Impact |
|---------------|-------------|---------------|
| MIPS/MSU consumption | IBM processor-based licensing | Very High — escalates with workload growth |
| z/OS licensing | Operating system license fees | High — tied to MIPS |
| CICS licensing | Transaction server license | High — per-MIPS pricing |
| DB2 licensing | Database license fees | High — per-MIPS pricing |
| ISV software | Third-party tools (monitoring, middleware) | Medium to High — often MIPS-based |
| Hardware maintenance | IBM hardware support contracts | High — increases with age |
| Facility costs | Power, cooling, floor space | Medium — significant if last mainframe workload |
| DR costs | Secondary mainframe or DR contract | High — often 50-70% of primary cost |
| Staff costs | Specialized mainframe operators and programmers | High — premium salaries, shrinking talent pool |

### Organizational Readiness Assessment

Modernization specialists need to understand the team landscape to recommend the right approach and timeline:

| Factor | Evidence to Capture |
|--------|-------------------|
| COBOL expertise | Number of COBOL-skilled staff, retirement timeline, knowledge documentation status |
| Java/Spring Boot skills | Current Java team size, training plans, hiring pipeline |
| Dual-skilled resources | Staff who understand both COBOL and Java (bridge resources) |
| Operations team | Current monitoring/ops practices, cloud-native readiness |
| Business stakeholder availability | SME availability for business rule validation and UAT |
| Executive sponsorship | Funding model, multi-year commitment, organizational priority |
| Change management | Existing change management processes and readiness |

### Testing Strategy Considerations (COBOL-Specific)

Modernization specialists need to understand the testing landscape to plan validation:

| Test Type | Purpose | Approach |
|-----------|---------|----------|
| Output equivalence | Prove Java output matches mainframe | Automated field-by-field comparison |
| EBCDIC sort order | Validate comparison/sort logic | Test all >, <, >=, <= operations |
| Numeric boundary | Validate data type conversions | Test at PIC clause boundaries, signed/unsigned |
| Financial precision | Validate decimal/rounding accuracy | Compare every financial calculation to penny |
| Batch chain | Validate multi-step job sequences | End-to-end batch chain with restart scenarios |
| Performance/stress | Validate throughput under load | Production-equivalent volume testing |
| Parallel run | Final validation before cutover | Run both systems simultaneously, compare outputs |
| Test data capture | Enable all above testing | Capture production data and scenarios from day one |


## Business Logic Extraction Framework

This section defines how to exhaustively extract, categorize, and document ALL business logic from COBOL programs. This is the most critical input to the modernization report — without a complete business logic inventory, modernization specialists cannot plan effectively.

### Extraction Approach

For EVERY COBOL program in scope, analyze the PROCEDURE DIVISION line by line and extract business rules into the categories below. Each rule must reference the specific paragraph name and code location where it is implemented.

### Category 1: Input Validation Rules

Extract ALL data validation logic — every field check, format validation, and required-field enforcement.

| Rule ID | Field Name | Validation Type | Condition | Error Action | Source Location |
|---------|-----------|----------------|-----------|-------------|-----------------|
| VR-nnn | Field being validated | Required / Format / Range / Cross-field / Referential | Exact condition from code | Error message and recovery action | Paragraph name |

Look for: required field checks (spaces, low-values, zeros), numeric range validation, format validation (date formats, alphanumeric patterns), cross-field validation, referential validation, length validation, character set validation, business constraint validation.

### Category 2: Calculation and Processing Rules

Extract ALL business calculations, formulas, data transformations, and processing logic.

| Rule ID | Rule Description | Formula/Logic | Input Fields | Output Fields | Rounding/Precision | Source Location |
|---------|-----------------|---------------|-------------|--------------|-------------------|-----------------|
| PR-nnn | What the calculation does | Exact formula or COMPUTE statement | Fields used as input | Fields that receive results | Rounding rules if any | Paragraph name |

Look for: arithmetic (COMPUTE, ADD, SUBTRACT, MULTIPLY, DIVIDE), rounding rules (ROUNDED keyword), accumulation logic, data transformation, date calculations, rate calculations, proration/allocation, currency formatting.

### Category 3: Decision and Routing Rules

Extract ALL conditional logic that determines program flow, user routing, or business outcomes.

| Rule ID | Condition | True Action | False Action | Business Meaning | Source Location |
|---------|-----------|-------------|-------------|-----------------|-----------------|
| DR-nnn | Exact condition from EVALUATE/IF | Action when true | Action when false | Business interpretation | Paragraph name |

Look for: EVALUATE statements (all WHEN clauses), IF/ELSE chains (every branch), 88-level condition name usage, EIBAID processing (every PF key), user type routing, status-based branching, threshold-based decisions, priority/precedence logic.

### Category 4: Data Access Rules

Extract ALL file/database access patterns, including keys, access modes, and business context.

| Rule ID | Resource | Operation | Key/Criteria | Success Logic | Failure Logic | Business Purpose | Source Location |
|---------|----------|-----------|-------------|--------------|--------------|-----------------|-----------------|
| DA-nnn | File or table name | READ/WRITE/REWRITE/DELETE/STARTBR | Key field(s) | What happens on success | What happens on error | Why this access exists | Paragraph name |

Look for: VSAM KSDS reads, browse operations (STARTBR/READNEXT/READPREV), writes, rewrites, deletes, DB2 SELECT/INSERT/UPDATE/DELETE, cursor processing, sequential file I/O, file status code handling.

### Category 5: Inter-Program Communication Rules

Extract ALL data passed between programs and the business rules governing that communication.

| Rule ID | Source Program | Target Program | Transfer Method | Data Passed | Business Purpose | Conditions | Source Location |
|---------|---------------|---------------|----------------|------------|-----------------|-----------|-----------------|
| IC-nnn | Calling program | Called program | CALL/XCTL/LINK | COMMAREA fields or parameters | Why this transfer occurs | When this transfer happens | Paragraph name |

Look for: COMMAREA field population/consumption, program routing logic, return code handling, session/context propagation, error propagation between programs.


### Category 6: Error Handling and Recovery Rules

Extract ALL error conditions, error messages, and recovery procedures.

| Rule ID | Error Condition | Error Source | User Message | Recovery Action | Severity | Source Location |
|---------|----------------|-------------|-------------|----------------|----------|-----------------|
| EH-nnn | What triggers the error | CICS RESP / FILE STATUS / business condition | Exact message text | What the program does to recover | Critical/Warning/Info | Paragraph name |

Look for: CICS RESP/RESP2 handling, FILE STATUS handling, DB2 SQLCODE handling, business rule violations, resource unavailable errors, ABEND handling, error message literals, cursor positioning on error, error flag setting.

### Category 7: Screen/Interface Rules (CICS Programs)

Extract ALL screen interaction logic for BMS-based CICS programs.

| Rule ID | Map/Field | Direction | Business Rule | Attribute Control | Source Location |
|---------|----------|-----------|--------------|-------------------|-----------------|
| SR-nnn | Map name and field name | Input/Output | What the field does and its constraints | Color, protection, cursor positioning | Paragraph name |

Look for: initial screen display logic, field population logic, field attribute manipulation, cursor positioning, screen clearing, message area population, PF key labeling, screen flow sequences.

### Category 8: Batch Processing Rules (Batch Programs)

Extract ALL batch-specific business logic for JCL/batch COBOL programs.

| Rule ID | Job/Step | Rule Description | Input | Output | Condition | Source Location |
|---------|---------|-----------------|-------|--------|-----------|-----------------|
| BR-nnn | JCL job and step name | What the batch rule does | Input files/parameters | Output files/reports | When this rule applies | Paragraph name |

Look for: record selection criteria, sort/merge criteria, control break logic, report formatting rules, checkpoint/restart logic, file matching logic, accumulation/summarization, date-based processing, conditional step execution, return code propagation.

### Category 9: Security and Authorization Rules

Extract ALL security-related business logic.

| Rule ID | Security Function | Mechanism | Condition | Action | Source Location |
|---------|------------------|-----------|-----------|--------|-----------------|
| SEC-nnn | What security function | How it is implemented | When it applies | What happens | Paragraph name |

Look for: user authentication logic, user authorization logic, resource-level security, password validation rules, session management, audit trail generation, data masking/redaction, encryption/decryption.

### Category 10: Temporal and State Management Rules

Extract ALL time-based logic and state management patterns.

| Rule ID | Rule Description | Time/State Element | Condition | Action | Source Location |
|---------|-----------------|-------------------|-----------|--------|-----------------|
| TM-nnn | What the rule does | Date field, status field, or state flag | When it triggers | What happens | Paragraph name |

Look for: date-based business rules, status transitions, aging calculations, scheduling logic, pseudo-conversational state management, flag-based state tracking, counter-based logic.

### Extraction Completeness Checklist

For each COBOL program analyzed, verify:
- [ ] Every EVALUATE statement has ALL WHEN clauses documented
- [ ] Every IF/ELSE chain has ALL branches documented (including ELSE)
- [ ] Every 88-level condition name usage is documented with business meaning
- [ ] Every EXEC CICS command is documented with its business purpose
- [ ] Every EXEC SQL statement is documented with its business purpose
- [ ] Every PERFORM target paragraph has its business logic extracted
- [ ] Every file READ/WRITE/REWRITE/DELETE has success AND failure paths documented
- [ ] Every error message literal is captured exactly as coded
- [ ] Every COMMAREA field has its population and consumption logic documented
- [ ] Every CALL/XCTL/LINK has its conditions and data passing documented
- [ ] Every COMPUTE/ADD/SUBTRACT/MULTIPLY/DIVIDE has its formula documented
- [ ] Every MOVE that transforms data (not just copies) is documented
- [ ] Every STRING/UNSTRING operation is documented
- [ ] Every INSPECT operation is documented
- [ ] Dead code paths are identified and marked as candidates for elimination


### Business Logic Summary Table (Per Program)

After extraction, produce a summary for each program:

| Category | Rule Count | Critical | High | Medium | Low |
|----------|-----------|----------|------|--------|-----|
| Input Validation | [count] | [count] | [count] | [count] | [count] |
| Calculation/Processing | [count] | [count] | [count] | [count] | [count] |
| Decision/Routing | [count] | [count] | [count] | [count] | [count] |
| Data Access | [count] | [count] | [count] | [count] | [count] |
| Inter-Program Communication | [count] | [count] | [count] | [count] | [count] |
| Error Handling | [count] | [count] | [count] | [count] | [count] |
| Screen/Interface | [count] | [count] | [count] | [count] | [count] |
| Batch Processing | [count] | [count] | [count] | [count] | [count] |
| Security/Authorization | [count] | [count] | [count] | [count] | [count] |
| Temporal/State Management | [count] | [count] | [count] | [count] | [count] |
| **Total** | **[total]** | **[total]** | **[total]** | **[total]** | **[total]** |

Criticality levels:
- Critical: Rule failure causes data corruption, financial loss, or security breach
- High: Rule failure causes incorrect business outcomes or user-facing errors
- Medium: Rule failure causes degraded functionality or workaround needed
- Low: Rule failure causes cosmetic issues or minor inconvenience

### Business Logic Dependency Map

After extracting all rules, produce a cross-program dependency map showing which business rules span multiple programs:

```mermaid
graph TD
    subgraph "Authentication Rules"
        VR1[VR-001: User ID Validation]
        VR2[VR-002: Password Validation]
        DA1[DA-001: USRSEC File Read]
    end
    subgraph "Routing Rules"
        DR1[DR-001: User Type Check]
        IC1[IC-001: Admin Program Transfer]
        IC2[IC-002: User Program Transfer]
    end
    subgraph "Session Rules"
        IC3[IC-003: COMMAREA Population]
        TM1[TM-001: Session State Setup]
    end

    VR1 --> DA1
    VR2 --> DA1
    DA1 --> DR1
    DR1 --> IC1
    DR1 --> IC2
    IC1 --> IC3
    IC2 --> IC3
    IC3 --> TM1
```

This diagram must be generated from actual extracted rules, showing the real dependency chain of business logic across the application.

### Migration Impact Assessment Per Business Rule

For each extracted business rule, assess migration impact to help modernization specialists prioritize:

| Rule ID | Rule Description | Migration Complexity | Java Pattern | Specialist Attention | Notes |
|---------|-----------------|---------------------|-------------|---------------------|-------|
| VR-001 | User ID required | Low | Bean Validation `@NotBlank` | Standard | Direct mapping |
| PR-001 | Interest calculation | High | `BigDecimal` with specific rounding | Precision validation required | Must validate rounding behavior |
| DR-001 | User type routing | Medium | Spring Security roles | Role model design | May require role model redesign |
| DA-001 | VSAM key read | Medium | JPA `findById()` | Key structure review | Key structure may change |
| EH-001 | RESP code 13 handling | Low | `@ExceptionHandler` | Standard | Direct mapping |

This table connects business logic extraction directly to migration planning, making it actionable for the modernization team.

## Mechanical Data Inventory Extraction

Use targeted regex searches across the entire codebase FIRST, then read specific files only for detail. Every inventory must be cross-referenced against at least two independent sources.

### VSAM File Inventory (must match CSD + LISTCAT + program usage)

**Source 1 — CSD file definitions:** `grepSearch: query="DEFINE FILE" includePattern="**/*.csd"`
**Source 2 — LISTCAT metadata:** `grepSearch: query="CLUSTER|KEYLEN|AVGLRECL|MAXLRECL|REC-TOTAL" includePattern="**/LISTCAT*"`
**Source 3 — AIX and PATH:** `grepSearch: query="^0AIX|^0PATH" includePattern="**/LISTCAT*"`
**Cross-reference:** `grepSearch: query="DATASET|FILE" includePattern="**/*.cbl"`

Completeness check: DEFINE FILE count in CSD must match VSAM clusters in LISTCAT. Every CSD file must appear in at least one program.

Output table (REQUIRED): CICS File | VSAM Dataset | Type | Key Len | Rec Len | Records | Programs | PostgreSQL Target

### Batch Data File Inventory

Scan data directories, cross-reference with JCL DD statements, match to copybook record layouts.

Output table (REQUIRED): File Name | Format | Record Layout Copybook | Record Length | JCL Jobs | PostgreSQL Target

### DB2 Table Inventory (must match DDL + DCL + program SQL)

**Source 1 — DDL:** `grepSearch: query="CREATE TABLE" includePattern="**/*.ddl"`
**Source 2 — DCL:** `grepSearch: query="EXEC SQL DECLARE.*TABLE" includePattern="**/*.dcl"`
**Source 3 — Embedded SQL:** `grepSearch: query="EXEC SQL" includePattern="**/*.cbl"`
**Source 4 — SQL INCLUDE:** `grepSearch: query="EXEC SQL.*INCLUDE" includePattern="**/*.cbl"`

Completeness check: Every DDL table must have a DCL. Every program SQL table must appear in DDL. Every DCL INCLUDE must resolve.

Output table (REQUIRED): Table | Columns | Primary Key | Foreign Keys | DDL File | Programs | SQL Operations

### IMS Database Inventory

Search for: `*.dbd`, `*.psb`, `CBLTDLI|AIBTDLI` in .cbl files.

### MQ Queue Inventory

Search for: `MQGET|MQPUT|MQPUT1|MQOPEN|MQCLOSE` and queue name patterns in .cbl files.

### Exhaustive Copybook Data Type Mapping

Step 1: List ALL copybooks in every cpy directory.
Step 2: Read EVERY copybook — extract 01-level record, all fields with PIC clauses, all 88-levels, all REDEFINES.
Step 3: Map EVERY field using conversion table:

| PIC Pattern | PostgreSQL | Java | Notes |
|-------------|-----------|------|-------|
| `X(n)` | VARCHAR(n) | String | |
| `9(1-4)` | SMALLINT | int | |
| `9(5-9)` | INTEGER | int | |
| `9(10-18)` | BIGINT | long | |
| `S9(n)V9(m)` | NUMERIC(n+m,m) | BigDecimal | Financial — CRITICAL |
| `S9(n) COMP` | INTEGER/BIGINT | int/long | Binary storage |
| `S9(n) COMP-3` | NUMERIC | BigDecimal | Packed decimal |
| `X(10)` with DATE in name | DATE | LocalDate | |
| `X(26)` with TS in name | TIMESTAMP | Instant | |

Step 4: Cross-reference copybooks to programs via `grepSearch: query="COPY " includePattern="**/*.cbl"`.

Completeness check: Every copybook must have a data type mapping table. Every COPY statement must resolve.

Output (REQUIRED): One data type mapping table PER copybook showing every field.

### CICS Transaction Inventory (must match CSD + menu copybooks + programs)

**Source 1 — CSD transactions:** `grepSearch: query="DEFINE TRANSACTION" includePattern="**/*.csd"`
**Source 2 — CSD programs:** `grepSearch: query="DEFINE PROGRAM" includePattern="**/*.csd"`
**Source 3 — Menu copybooks:** `grepSearch: query="CDEMO-MENU-OPT|CDEMO-ADMIN-OPT" includePattern="**/*.cpy"`
**Source 4 — BMS mapsets:** `grepSearch: query="DEFINE MAPSET" includePattern="**/*.csd"`

Output tables (REQUIRED):
1. Online Transactions: Trans ID | Program | Function | REST API Target
2. Regular User Menu Options: # | Option | Program | Access Level
3. Admin Menu Options: # | Option | Program
4. Batch Programs: Program | Function | Spring Batch Target
5. Sub-Application Programs: Program | Sub-App | Function

## Mechanical Business Rule Extraction Procedures

The Business Logic Extraction Framework (above) defines 10 categories. This section specifies HOW to mechanically find every rule using codebase-wide searches. Use these searches FIRST, then read surrounding context only where needed.

### Procedure for Input Validation Rules

1. Required fields: `grepSearch: query="= SPACES|= LOW-VALUES|= ZEROS" includePattern="**/*.cbl"`
2. Numeric validation: `grepSearch: query="IS NOT NUMERIC|IS NUMERIC" includePattern="**/*.cbl"`
3. Validation flags: `grepSearch: query="88.*FLG-.*VALUE" includePattern="**/*.cbl"`
4. Range/list validations: `grepSearch: query="VALUES.*THRU|88.*VALUES '" includePattern="**/*.cpy"`
5. EVALUATE TRUE blocks: `grepSearch: query="EVALUATE TRUE" includePattern="**/*.cbl"` — read 30-50 lines context
6. Error messages (confirms validations): `grepSearch: query="MOVE '.*' TO WS-MESSAGE|MOVE '.*' TO WS-RETURN-MSG" includePattern="**/*.cbl"`

Completeness: validation rule count must be >= distinct error message count.

### Procedure for Calculation/Processing Rules

1. All arithmetic: `grepSearch: query="COMPUTE |ADD .* TO |SUBTRACT .* FROM |MULTIPLY .* BY |DIVIDE .* BY " includePattern="**/*.cbl"`
2. Financial fields (CRITICAL): `grepSearch: query="CURR-BAL|CREDIT-LIMIT|TRAN-AMT|INT-RATE|CAT-BAL|PAGE-TOTAL|GRAND-TOTAL" includePattern="**/*.cbl"`
3. FUNCTION calls: `grepSearch: query="FUNCTION " includePattern="**/*.cbl"`
4. String operations: `grepSearch: query="STRING |UNSTRING |INSPECT " includePattern="**/*.cbl"`
5. Report formatting: `grepSearch: query="PIC .*Z.*\\.|PIC \\+|PIC -" includePattern="**/*.cbl"`

Completeness: every COMPUTE/ADD/SUBTRACT/MULTIPLY/DIVIDE must appear as a rule.

### Procedure for Decision/Routing Rules

1. XCTL transfers: `grepSearch: query="XCTL PROGRAM" includePattern="**/*.cbl"`
2. LINK calls: `grepSearch: query="EXEC CICS LINK" includePattern="**/*.cbl"`
3. PF key handling: `grepSearch: query="EIBAID|DFHENTER|DFHPF" includePattern="**/*.cbl"`
4. User type routing: `grepSearch: query="USRTYP-ADMIN|USRTYP-USER|USR-TYPE" includePattern="**/*.cbl"`
5. Menu option tables: `grepSearch: query="OPT-PGMNAME|OPT-NAME|OPT-COUNT" includePattern="**/*.cpy"`

### Procedure for Data Access Rules

1. All CICS file I/O: `grepSearch: query="EXEC CICS (READ|WRITE|REWRITE|DELETE|STARTBR|READNEXT|READPREV|ENDBR)" includePattern="**/*.cbl"`
2. All DB2 SQL: `grepSearch: query="EXEC SQL" includePattern="**/*.cbl"`
3. MQ operations: `grepSearch: query="CALL 'MQ" includePattern="**/*.cbl"`
4. TD/TS queues: `grepSearch: query="WRITEQ TD|READQ TD|WRITEQ TS|READQ TS" includePattern="**/*.cbl"`
5. Batch file I/O: `grepSearch: query="OPEN |CLOSE |READ |WRITE " includePattern="**/CB*.cbl"`

### Procedure for Security Rules

1. Password handling: `grepSearch: query="USR-PWD|PASSWORD|PASSWD" includePattern="**/*.cbl"`
2. User type checks: `grepSearch: query="USRTYP|USR-TYPE|USER-TYPE" includePattern="**/*.cbl"`
3. Session context: `grepSearch: query="CDEMO-USER-ID|CDEMO-FROM-PROGRAM|CDEMO-TO-PROGRAM" includePattern="**/*.cbl"`
4. CSD security: `grepSearch: query="RESSEC|CMDSEC" includePattern="**/*.csd"`

### Procedure for Error Handling Rules

1. CICS RESP: `grepSearch: query="RESP\\(|DFHRESP" includePattern="**/*.cbl"`
2. Error messages: `grepSearch: query="MOVE '.*' TO WS-MESSAGE|MOVE '.*' TO WS-RETURN-MSG|MOVE '.*' TO ERRMSGO" includePattern="**/*.cbl"`
3. 88-level messages: `grepSearch: query="88.*VALUE$" includePattern="**/*.cbl"`
4. ABEND handling: `grepSearch: query="HANDLE ABEND|ABEND-CODE" includePattern="**/*.cbl"`
5. DB2 SQLCODE: `grepSearch: query="SQLCODE|SQLCA" includePattern="**/*.cbl"`
6. MQ errors: `grepSearch: query="MQ-REASON-CODE|MQ-CONDITION-CODE|MQRC-" includePattern="**/*.cbl"`
7. Batch file status: `grepSearch: query="FILE-STATUS|STATUS = '00'|STATUS NOT" includePattern="**/*.cbl"`

Completeness: every error message literal must appear as an EH rule.

### Procedure for Batch Processing Rules

1. JCL programs: `grepSearch: query="EXEC PGM=" includePattern="**/*.jcl"`
2. JCL datasets: `grepSearch: query="DD.*DSN=" includePattern="**/*.jcl"`
3. Sort/merge: `grepSearch: query="SORT|MERGE|DFSORT" includePattern="**/*.jcl"`

### Expected Rule Counts (Quality Gate)

For a typical COBOL/CICS application (~40 programs, ~30 copybooks, ~40 JCL jobs):

| Category | Expected Minimum | If Below, Re-run Searches |
|----------|-----------------|--------------------------|
| Input Validation | 25-40 | Re-scan EVALUATE TRUE blocks and error messages |
| Calculation/Processing | 10-20 | Re-scan all COMPUTE/ADD/SUBTRACT and financial fields |
| Decision/Routing | 5-15 | Re-read all menu copybooks and XCTL calls |
| Data Access | 25-40 | Re-scan all VSAM files x all programs, all DB2 SQL |
| Security | 3-8 | Re-scan password handling and user type checks |
| Error Handling | 10-25 | Re-capture all error message literals |
| **Total** | **80-150** | If total < 80, extraction is incomplete |

## Report Internal Consistency Rules

When generating or editing a COBOL/Mainframe modernization report, every inventory and analysis section MUST be internally consistent, non-contradictory, complete, and explainable. A reader must be able to follow a clear rationale from any summary table to its corresponding detail section without encountering unexplained gaps or mismatched numbers.

### General Business Logic Consistency Principles

1. **Summary-to-Detail Traceability**: Every summary table row MUST have a corresponding detail subsection. Every number in a summary table MUST be verifiable by counting rows in the detail tables.
2. **No Phantom Categories**: If a summary table lists N categories, there MUST be exactly N detail subsections — no more, no fewer.
3. **No Phantom Counts**: If a summary table claims X rules/items in a category, the detail subsection MUST contain exactly X rows.
4. **Consistent Naming**: Category names in summary tables MUST match subsection headings exactly. Do not use "Financial Calculation Rules" in a detail heading if the summary table says "Calculation/Processing".
5. **Severity Breakdown Verification**: If a summary table has columns for severity levels (Critical/High/Medium/Low), each detail subsection heading MUST declare its breakdown (e.g., "4 Critical, 10 High, 8 Medium, 6 Low = 28 total") and the individual rule rows MUST include a Severity column so the counts are independently verifiable.
6. **Cross-Total Verification**: Row totals (Critical+High+Medium+Low) MUST equal the Rule Count column. Column totals MUST equal the Total row. The grand total MUST equal the sum of all category Rule Counts.
7. **Source Traceability**: Every rule, data access pattern, or inventory item MUST cite a specific source program, copybook, DDL file, or JCL job that can be found in the codebase.

### Business Logic Summary & Key Business Rules Consistency

#### Structure Requirements

- The summary table MUST list ALL categories with columns: Category, Rule Count, Critical, High, Medium, Low.
- The "Key Business Rules Extracted" section MUST contain one subsection per category row.
- Each subsection MUST list exactly the number of rules claimed in the summary table for that category.
- Each rule row MUST have: Rule ID (unique, sequential within category), Severity, description columns, and Source (program name).
- The severity values in each row MUST match the counts declared in the subsection heading and the summary table.

#### Methodology Note Requirements

- A methodology note MUST explain what was scanned (source file types), what constitutes a "rule", and the total count.
- The total count in the methodology note MUST match the summary table grand total.
- Do NOT reference a different number than what the summary table shows.

#### What Counts as a Business Rule

Each rule must be a distinct, identifiable construct from the source code:
- **Input Validation**: An explicit check (IF/EVALUATE) that rejects or flags invalid input — one rule per distinct validation check.
- **Calculation/Processing**: An arithmetic operation (ADD, COMPUTE, SUBTRACT) or implied-decimal field definition requiring BigDecimal mapping — one rule per distinct calculation or critical field.
- **Decision/Routing**: An EVALUATE or IF that determines program flow (XCTL target, menu dispatch, processing branch) — one rule per distinct decision point.
- **Data Access**: A CICS READ/WRITE/REWRITE/DELETE/STARTBR/READNEXT/READPREV, EXEC SQL, or IMS DL/I call — one rule per distinct file+operation+program combination.
- **Inter-Program Communication**: An XCTL, MQ call (MQOPEN/MQGET/MQPUT/MQCLOSE), DL/I CALL, TD queue write, or external program CALL — one rule per distinct communication pattern.
- **Error Handling**: A DFHRESP/SQLCODE/MQRC check with a specific user-facing message or recovery action — one rule per distinct error condition handled.
- **Screen/Interface**: A BMS SEND/RECEIVE pattern, PF key handler, cursor positioning, or field attribute manipulation — one rule per distinct screen interaction pattern.
- **Batch Processing**: A batch job's primary processing logic (file scan, report generation, data extract, database load/unload) — one rule per distinct batch function.
- **Security/Authorization**: An authentication check, access control decision, or credential management operation — one rule per distinct security function.
- **Temporal/State Management**: A pseudo-conversational state check, change detection comparison, or pagination state tracking — one rule per distinct state management pattern.

### Inventory Consistency Rules

#### VSAM File Inventory

- Every VSAM file referenced in CSD definitions or CICS programs MUST appear in the inventory table.
- Columns MUST include: CICS File name, VSAM Dataset name, Type (KSDS/AIX/PATH), Key Length, Record Length, Programs that access it, and PostgreSQL target table.
- The "Programs" column MUST list only programs where the file access is actually coded (EXEC CICS READ/WRITE with that file's DD name).
- AIX/PATH entries MUST reference their base cluster.

#### DB2 Table Inventory

- Every table referenced in DDL files or EXEC SQL statements MUST appear in the inventory.
- Columns MUST include: Table name, Column count, Primary Key, Foreign Keys, DDL File, Programs, SQL Operations.
- The "SQL Operations" column MUST list only operations actually found in the source (SELECT, INSERT, UPDATE, DELETE).
- The "Programs" column MUST match programs containing EXEC SQL statements referencing that table.

#### IMS Database Inventory

- Every DBD and PSB file in the codebase MUST appear in the inventory.
- Columns MUST include: DBD name, PSB name(s), Type (HIDAM/HDAM/etc.), Programs, Purpose.
- Programs listed MUST actually contain DL/I calls referencing those PSBs.

#### MQ Queue Inventory

- Every MQ queue referenced in MQOPEN/MQPUT/MQGET calls MUST appear in the inventory.
- Columns MUST include: Queue name/purpose, Direction (Input/Output), Programs, Purpose.
- Programs listed MUST contain the actual MQ API calls.

#### Copybook Data Type Mapping

- Every copybook used in COPY statements across the COBOL programs MUST be considered for inclusion.
- At minimum, copybooks defining record layouts for VSAM files, DB2 tables, and COMMAREA structures MUST be mapped.
- Columns MUST include: COBOL Field, PIC Clause, PostgreSQL type, Java type, Notes.
- Financial fields (PIC S9(n)V99) MUST be flagged as "Financial — CRITICAL" and mapped to BigDecimal.
- PII fields (SSN, DOB, phone, government ID) MUST be flagged as "PII" or "PII — encrypt".

#### CICS Transaction Inventory

- Every CICS transaction ID defined in CSD files or referenced in RETURN TRANSID statements MUST appear.
- Online transactions MUST include: Trans ID, Program, Function description, REST API Target.
- The REST API Target MUST follow consistent naming conventions (e.g., GET/POST/PUT/DELETE /api/resource).
- Sub-application transactions MUST be listed separately with their sub-app context.
- Menu option tables MUST match the copybook definitions (COMEN02Y, COADM02Y).

### Report Anti-Patterns to Avoid

1. **Never** list rules in a detail section under a heading labeled "(Critical)" if the section contains rules of mixed severity — use the full breakdown format instead.
2. **Never** use a category name in a detail heading that doesn't exist in the summary table.
3. **Never** claim a total of N rules in a methodology note while the summary table shows a different number.
4. **Never** list only a subset of categories from the summary table in the detail section without explaining why others are omitted.
5. **Never** list more or fewer rules in a detail subsection than the summary table claims for that category.

## Cross-Reference Validation (Final Quality Gate)

Before finalizing the report, run these validation checks:

1. **Copybook-to-Program Matrix:** Every copybook must be referenced by at least one program. Unreferenced copybooks are dead code.
2. **File-to-Program Matrix:** Every VSAM file in CSD must be accessed by at least one program. Every DB2 table in DDL must be accessed.
3. **Transaction-to-Program Matrix:** Every CSD DEFINE TRANSACTION must map to a DEFINE PROGRAM. Every menu option program must exist.
4. **Data Type Mapping Completeness:** Every .cpy file must have a data type mapping table. Expect 80-120+ fields for a CardDemo-sized app.
5. **Business Rule Count Validation:** Verify against Expected Rule Counts table. If any category is below minimum, re-run searches.
