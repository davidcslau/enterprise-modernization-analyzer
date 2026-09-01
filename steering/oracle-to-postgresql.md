---
inclusion: manual
---

# Oracle to PostgreSQL Migration — Workstream Analysis

## Objective

Size and de-risk an Oracle → PostgreSQL (Amazon Aurora PostgreSQL or Amazon RDS for PostgreSQL)
database migration as a **workstream of its own**, running alongside the application migration rather
than as a footnote to it.

## ⛔ Load Only When Scope Is Confirmed

This file is dispatched by POWER.md Step 2 **only** when Oracle is detected **and** the user has
confirmed that Oracle → PostgreSQL migration is in scope. Database migration scope is never assumed
in either direction:

- Some programmes treat Oracle → PostgreSQL as a committed workstream with its own sizing, driven by
  licence elimination. This analysis is for those.
- Other programmes deliberately keep the database unchanged so the application migration is the only
  variable, and design the target to **avoid database change**. For those, report the Oracle footprint
  and stop — do not present this conversion analysis as a recommendation.

If scope has not been confirmed, the correct output is the footprint plus the scope question, not a
migration plan. See the Database Detection section in POWER.md.

**This is a full workstream, not a schema conversion.** It has its own inventory, its own conversion
effort, its own testing requirement and its own cutover. Where it runs concurrently with an
application migration, say so plainly: two simultaneous changes to the same system is a compounding
risk that the report should surface rather than smooth over.

## 1. Oracle Version, Edition and Topology

Establish these first — edition in particular constrains what has to be replaced, because
Enterprise-only features have no PostgreSQL equivalent and need architectural workarounds.

| What to establish | Detection signals |
|-------------------|-------------------|
| **Version** | `v$version` output if available; JDBC driver version (`ojdbc6`/`7`/`8`/`11`); connection strings; documentation. Report 11g / 12c / 18c / 19c / 21c / 23ai |
| **Edition** | Standard Edition, Standard Edition 2, or Enterprise Edition. **This is the single most consequential fact in this section** |
| **RAC (Real Application Clusters)** | Multiple SCAN addresses or several hosts in the connection string, `(LOAD_BALANCE=`, `(FAILOVER=` in `tnsnames.ora`, RAC-aware connection pool configuration |
| **Multitenant / CDB-PDB** | Service names with PDB naming, `CONTAINER=` clauses |
| **Exadata** | Exadata-specific features, smart-scan-dependent query patterns, storage indexes |
| **Data Guard / GoldenGate** | Standby configuration, replication processes, GoldenGate trail references |
| **Character set** | `AL32UTF8`, `WE8ISO8859P1` and similar. A non-Unicode source character set means the migration includes a character-set conversion with its own data-integrity risk |
| **Connection method** | `tnsnames.ora` + TNS alias, EZConnect, JDBC thin vs OCI/thick driver. An OCI thick-driver dependency means native Oracle client libraries are installed on application hosts, which is also a containerization finding |

### Enterprise-Only Features and Their PostgreSQL Position

For each feature found, report what it does today and what the PostgreSQL approach would be. These
are the items that turn a schema conversion into an architecture change.

| Oracle Enterprise feature | Detection | PostgreSQL position and workaround |
|---------------------------|-----------|-----------------------------------|
| **Partitioning** | `PARTITION BY RANGE/LIST/HASH` in DDL, partition-aware queries, partition maintenance jobs | PostgreSQL has declarative partitioning (10+), so the capability exists — but **interval partitioning has no equivalent** and automatic partition creation must be scripted. Partition-wise joins and pruning behaviour differ. Report the partitioning scheme and the maintenance automation that goes with it |
| **Advanced Compression** | Compressed tablespaces or table-level compression | No direct equivalent. PostgreSQL has TOAST compression for large values only. Consequence is **storage sizing**, so size the target on uncompressed volume rather than the current footprint |
| **RAC** | See above | No equivalent. Aurora PostgreSQL provides a writer plus readers with automatic failover, which is a **different availability and scaling model** — RAC's multiple concurrently-writable instances have no counterpart. Applications relying on RAC for write scaling need a design change; those using it for HA map onto Aurora reasonably |
| **In-Memory Column Store** | `INMEMORY` clauses | No equivalent. Analytical queries relying on it need re-planning, indexing, or a separate analytical target |
| **Result Cache** | `/*+ RESULT_CACHE */` hints, `RESULT_CACHE` table settings | No equivalent. Application-level or ElastiCache caching |
| **Parallel Query / DOP** | `PARALLEL` hints, `DEGREE` settings | PostgreSQL has parallel query but with a different planner model and different tuning. Do not assume equivalent behaviour on the same queries |
| **Flashback Query / Flashback Table** | `AS OF TIMESTAMP`, `AS OF SCN`, `FLASHBACK TABLE` | No equivalent. Where used for **application logic** (as opposed to recovery) this needs redesign — typically explicit history tables or temporal columns. Where used for recovery, PITR covers it |
| **Materialized View fast refresh** | `REFRESH FAST ON COMMIT`, materialized view logs | PostgreSQL materialized views only support **full refresh**. Incremental-refresh views need redesign — triggers maintaining a summary table, or a scheduled full refresh with the staleness accepted. Flag this specifically: it is a behavioural change, not a syntax change |
| **Advanced Security / TDE** | Encrypted tablespaces, column encryption | Aurora/RDS encryption at rest covers the tablespace case. Column-level encryption needs `pgcrypto` or application-level encryption |
| **Database Vault / Label Security** | Vault realms, `OLS` policies | No equivalent. Access control moves to roles, row-level security and application logic |
| **Diagnostics/Tuning Pack** | AWR, ASH, SQL Tuning Advisor usage in operations | Performance Insights and `pg_stat_statements` cover much of the observability need, but the tooling and workflow differ. This is an **operations retraining finding** |

## 2. PL/SQL Inventory — the Most Labour-Intensive Part

**Volume drives effort here more than anything else in the migration**, so produce a real inventory
with counts rather than an impression. PL/SQL → PL/pgSQL is largely a rewrite: the languages are
similar enough to look easy and different enough to be error-prone.

| Object type | What to count | Why it matters |
|-------------|---------------|----------------|
| **Stored procedures** | Count, and lines of code | The bulk of the conversion. PostgreSQL 11+ has true procedures; earlier the distinction from functions was significant |
| **Functions** | Count, and lines of code | Generally converts more directly than procedures |
| **Packages** | Count, plus procedures and functions **per** package | **No PostgreSQL equivalent exists.** Packages become schemas containing individual routines, which loses the package spec/body split, package-private routines and overloading conventions. Report package count separately — it is a structural conversion, not a syntax conversion |
| **Package state** | Package-level variables declared in the package body | **No equivalent, and a genuine behaviour change.** Oracle package variables persist for the session; PostgreSQL has no session-scoped package state. Needs temporary tables, `SET`/`current_setting`, or application-held state. **Flag every package with state** — this is one of the most commonly missed conversion problems |
| **Triggers** | Count, by table and by event | PostgreSQL requires a separate trigger function plus a trigger declaration, so each Oracle trigger becomes two objects. `FOR EACH ROW` semantics and `:NEW`/`:OLD` map onto `NEW`/`OLD` |
| **Materialized views** | Count, and refresh mode for each | See the fast-refresh constraint above |
| **Views** | Count, and which use Oracle-specific constructs | Usually converts readily, but views built on `CONNECT BY` or `DECODE` carry that conversion with them |
| **Sequences** | Count, plus caching and cycling settings | Converts to PostgreSQL sequences or identity columns. Note `.NEXTVAL` call sites live in application code too |
| **Object types / VARRAYs / nested tables** | `CREATE TYPE`, collection types, `TABLE OF` | Oracle object-relational features. Composite types and arrays cover some cases; others need relational redesign |
| **Autonomous transactions** | `PRAGMA AUTONOMOUS_TRANSACTION` | **No equivalent.** Typically used for logging that must survive a rollback. Needs `dblink`, a background worker, or a redesign — flag each occurrence |
| **Database links** | `CREATE DATABASE LINK`, `@dblink` in queries | `postgres_fdw` / `oracle_fdw`, or an application-level integration. Each link is also a **coupling finding** for the integration inventory |
| **Java stored procedures** | `CREATE JAVA`, `LOADJAVA` | No equivalent. Must move into the application |
| **External procedures** | `EXTPROC`, C libraries called from PL/SQL | No equivalent. Must move into the application |

**Also report total PL/SQL lines of code**, since that is the closest available proxy for conversion
volume — as **inventory**, not as an effort estimate in hours or days.

**Identify business logic held in PL/SQL.** Where domain rules live in packages and procedures, the
migration has a choice the customer must make: convert the logic to PL/pgSQL and keep it in the
database, or move it into the application. Report the volume and the character of the logic so they can
decide; do not decide for them. This connects to B4 in `evaluation-framework.md`.

## 3. Oracle-Specific SQL Constructs

These appear in stored logic **and** in application code — embedded SQL strings, Hibernate native
queries, MyBatis mapper XML, JDBC statements, report definitions. Scan all of them, not just the
database.

| Oracle construct | PostgreSQL equivalent | Conversion note |
|------------------|----------------------|-----------------|
| `CONNECT BY` / `START WITH` / `PRIOR` | `WITH RECURSIVE` | A **structural rewrite**, not a substitution. `LEVEL`, `CONNECT_BY_ROOT`, `CONNECT_BY_ISLEAF` and `SYS_CONNECT_BY_PATH` each need explicit reconstruction in the recursive CTE |
| `DECODE(a, b, c, d)` | `CASE WHEN a = b THEN c ELSE d END` | Mechanical. Watch the NULL comparison: `DECODE` treats two NULLs as equal, `CASE ... WHEN =` does not |
| `NVL(a, b)` | `COALESCE(a, b)` | Mechanical |
| `NVL2(a, b, c)` | `CASE WHEN a IS NOT NULL THEN b ELSE c END` | Mechanical |
| `(+)` outer join operator | ANSI `LEFT JOIN` / `RIGHT JOIN` | Rewrite. Legacy `(+)` joins in complex multi-table queries are error-prone to convert — the join intent is easy to misread |
| `MERGE` | `INSERT ... ON CONFLICT DO UPDATE`, or `MERGE` on PostgreSQL 15+ | Semantics differ: `ON CONFLICT` requires a unique constraint, and Oracle `MERGE` with a `WHERE` on the update clause has no direct one-to-one form |
| `ROWNUM` | `LIMIT` / `ROW_NUMBER()` | Depends on usage. `WHERE ROWNUM <= n` becomes `LIMIT n`; `ROWNUM` used for pagination or inside a subquery needs `ROW_NUMBER() OVER (...)`. **Note the ordering trap**: `ROWNUM` is assigned before `ORDER BY`, so a naive conversion can silently change which rows are returned |
| `ROWID` | `ctid` (not stable), or a surrogate key | `ctid` changes on update, so it is **not** a safe `ROWID` substitute. Application code relying on `ROWID` needs a real key |
| `DUAL` | Omit the `FROM` clause entirely | `SELECT 1 FROM DUAL` becomes `SELECT 1`. PostgreSQL permits a `dual` view for compatibility, but removing it is cleaner |
| `sequence.NEXTVAL` / `.CURRVAL` | `nextval('sequence')` / `currval('sequence')` | Appears in DDL defaults, triggers **and** application SQL |
| `SYS_CONTEXT('USERENV', ...)` | `current_user`, `inet_client_addr()`, `current_setting()` | Each attribute maps differently, and some (`SESSIONID`, `MODULE`, `CLIENT_IDENTIFIER`) have no equivalent. Where used for audit or row-level security, that mechanism needs redesign |
| `TO_DATE(x, 'fmt')` / `TO_CHAR(d, 'fmt')` | `to_date` / `to_char` | Function names match, **format models do not**. `MM`/`MI` minute-vs-month, `HH24`, `RR` two-digit-year windowing, `DD-MON-RR` locale-dependent month abbreviations, and `J`/`SSSSS` all need checking individually |
| `SYSDATE` / `SYSTIMESTAMP` | `now()` / `current_timestamp` / `clock_timestamp()` | `SYSDATE` is date-with-time at second precision; PostgreSQL `now()` is transaction-start timestamp with microseconds. **A loop calling `SYSDATE` repeatedly gets advancing values; `now()` does not** — use `clock_timestamp()` where advancing time is intended |
| Date arithmetic (`d + 1`, `d2 - d1`) | `d + INTERVAL '1 day'`, `d2 - d1` returning an interval | Oracle date subtraction yields a **number of days**; PostgreSQL yields an `interval`. Arithmetic on the result behaves differently and this is a silent numeric-difference risk |
| `ADD_MONTHS`, `MONTHS_BETWEEN`, `LAST_DAY`, `TRUNC(date)` | `+ INTERVAL`, `date_part`/`age`, `date_trunc` | Mostly available, with differing edge-case behaviour at month ends |
| `INSTR`, `SUBSTR` | `strpos`/`position`, `substring` | `INSTR` with negative position or occurrence arguments has no single-function equivalent |
| `LISTAGG(x, ',')` | `string_agg(x, ',')` | Mechanical |
| `NULLS FIRST/LAST` defaults | Explicit `NULLS FIRST` / `NULLS LAST` | **Oracle and PostgreSQL default differently in `ORDER BY`.** Result ordering changes silently unless made explicit |
| Analytic functions (`OVER`, `PARTITION BY`, `RANK`, `LAG`) | Same syntax, broadly compatible | Generally portable; verify frame clause defaults |
| Hierarchical / string functions in views | As above | Conversion propagates into every dependent view |
| Optimizer hints (`/*+ INDEX(...) */`, `/*+ FULL(...) */`) | **No hint mechanism** | PostgreSQL has no query hints. Hints must be dropped and replaced by indexing, statistics and query rewriting. **Every hint is a signal that a query needed help**, so each one is a performance-testing target rather than something to silently discard |
| `PIVOT` / `UNPIVOT` | `CASE` aggregation, or `crosstab` from `tablefunc` | Rewrite |
| `EXCEPTION WHEN OTHERS` with `SQLCODE` | `EXCEPTION WHEN OTHERS` with `SQLSTATE` | Error codes differ entirely. Any code branching on specific Oracle error numbers (`-1` unique violation, `-1403` no data found) must be re-mapped to PostgreSQL SQLSTATEs |

### ⚠️ Silent Behaviour Change: Empty String Is Not NULL

**This one deserves separate treatment because nothing fails.** It is a correctness risk, not a syntax
issue, and grouping it with `DECODE` → `CASE` would bury it among mechanical rewrites.

**Oracle treats an empty string `''` as NULL.** PostgreSQL treats it as a zero-length string, which is
a distinct value that is **not** NULL.

The consequence:

- Nothing fails to compile. No error is raised. No conversion tool flags it.
- `WHERE col IS NULL` silently stops matching rows it used to match, because those rows now contain
  `''` rather than NULL.
- `WHERE col = ''` starts matching rows that Oracle would never have returned.
- `COALESCE(col, 'default')` stops substituting the default, because `''` is not NULL.
- `NOT NULL` constraints now accept `''`, so a column that was effectively mandatory becomes
  effectively optional.
- Concatenation differs: Oracle `'a' || NULL` yields `'a'`; PostgreSQL yields NULL.
- Length checks differ: `LENGTH('')` is NULL in Oracle, `0` in PostgreSQL.

**How to report it:**

- Flag it as a **high-priority finding in section 4** wherever the schema has nullable text columns
  that application code or PL/SQL compares to `''` or tests with `IS NULL`
- Locate the specific comparisons — `IS NULL` / `IS NOT NULL` on text columns, `= ''`, `!= ''`,
  `COALESCE` on text, `NVL` on text — and report where they are
- State that data migration itself must decide, per column, whether an Oracle NULL becomes NULL or
  `''` in PostgreSQL, and that the answer has to be consistent with what the application then expects
- State plainly that this class of defect **passes every compile and surfaces as wrong results in
  production**, which is why it needs deliberate test coverage rather than trust in the conversion tool

## 4. Oracle-Proprietary Features Beyond SQL

Each of these is an architectural change rather than a translation, because the capability leaves the
database entirely.

| Oracle feature | Detection | Target |
|----------------|-----------|--------|
| **Oracle Text** | `CONTAINS(`, `CTXCAT`/`CONTEXT` indexes, `CTX_DDL` calls | PostgreSQL full-text search (`tsvector`/`tsquery`/GIN), or Amazon OpenSearch Service where the search requirement is substantial. Scoring and relevance behaviour will differ, so search result ordering needs re-validation with the business |
| **Oracle Spatial (SDO_GEOMETRY)** | `SDO_` types and operators, spatial indexes | PostGIS, which is well-supported on Aurora and RDS PostgreSQL. Generally a good migration, but the type and function names all change |
| **Advanced Queuing (AQ)** | `DBMS_AQ`, `DBMS_AQADM`, queue tables, `ENQUEUE`/`DEQUEUE` calls | **Amazon SQS or SNS.** Messaging moves out of the database entirely, which is an architectural improvement but changes transactional semantics: an AQ enqueue participates in the database transaction, an SQS send does not. **Flag this** — it usually means introducing the transactional outbox pattern |
| **`DBMS_SCHEDULER` / `DBMS_JOB`** | Scheduler job definitions, `DBMS_JOB.SUBMIT` | **Amazon EventBridge Scheduler**, Spring `@Scheduled`, or `pg_cron`. Inventory every scheduled job — these are batch processes hiding inside the database and they are easy to miss entirely |
| **`UTL_FILE`** | `UTL_FILE.FOPEN`, directory objects | **Amazon S3** via the application, or `aws_s3` extension on Aurora. Also note the Oracle `DIRECTORY` objects and the filesystem paths they point at, which are a host-coupling finding |
| **`UTL_HTTP` / `UTL_SMTP` / `UTL_TCP`** | Outbound calls from PL/SQL | Move into the application — an HTTP client, or SES for mail. **Outbound network calls from inside the database are also an integration finding** for B9, and often undocumented |
| **`DBMS_OUTPUT`** | `DBMS_OUTPUT.PUT_LINE` | `RAISE NOTICE`. Mechanical, but where it is used as de facto logging, proper logging is the better target |
| **`DBMS_LOB`** | `DBMS_LOB.` calls, temporary LOBs | PostgreSQL `text`/`bytea` with standard functions, or large objects. Streaming semantics differ, and code that reads LOBs in chunks needs rework |
| **`DBMS_CRYPTO`** | Encryption/hashing in PL/SQL | `pgcrypto`. **Verify algorithm and padding compatibility** — existing encrypted data must remain decryptable, which constrains the choice |
| **`DBMS_RANDOM`** | Random value generation | `random()`, `gen_random_uuid()`. Note that seeded reproducibility differs |
| **`DBMS_SQL` / `EXECUTE IMMEDIATE`** | Dynamic SQL | `EXECUTE` in PL/pgSQL. Dynamic SQL is where Oracle-specific syntax hides from static analysis — **grep for concatenated SQL strings specifically** |
| **`DBMS_STATS`** | Statistics gathering jobs | `ANALYZE` and autovacuum. The maintenance model differs and operations procedures need rewriting |
| **`DBMS_METADATA`** | Schema introspection | `pg_catalog` / `information_schema` |
| **External tables** | `ORGANIZATION EXTERNAL`, `ACCESS PARAMETERS` | `file_fdw`, or load from S3. Often part of a batch interface, so it belongs in the integration inventory |
| **`SQL*Loader` control files** | `.ctl` files, `sqlldr` invocations | `COPY`, `pg_bulkload`, or an application loader. These are batch interfaces with upstream owners |
| **`SQL*Plus` scripts** | `.sql` scripts with `SET` directives, `@@` includes, `DEFINE` substitution variables, `EXIT SQL.SQLCODE` | `psql` scripts. Operational scripting is application-adjacent code that is routinely forgotten in scoping — inventory it |

## 5. Data Type Mapping

| Oracle type | PostgreSQL type | Conversion note |
|-------------|-----------------|-----------------|
| `NUMBER(p,s)` with scale | `numeric(p,s)` | Exact. Preserves precision |
| `NUMBER(p)` integer-like, p ≤ 4 | `smallint` | Choose by range |
| `NUMBER(p)` integer-like, p ≤ 9 | `integer` | Better performance than `numeric` |
| `NUMBER(p)` integer-like, p ≤ 18 | `bigint` | Better performance than `numeric` |
| `NUMBER` with **no** precision | `numeric` | Unconstrained. **Check actual stored values** before narrowing to an integer type — narrowing is a performance win but risks overflow if the data is wider than assumed |
| `NUMBER(1)` used as a flag | `boolean` or `smallint` | `boolean` is cleaner but changes application binding and every SQL comparison. Decide deliberately and consistently |
| `FLOAT` / `BINARY_FLOAT` | `real` | Precision differences at the edges |
| `BINARY_DOUBLE` | `double precision` | |
| `VARCHAR2(n)` | `varchar(n)` | **Check the length semantics**: `VARCHAR2(n CHAR)` vs `VARCHAR2(n BYTE)`. Oracle byte semantics with a multi-byte character set means the effective character limit is lower than `n`, and PostgreSQL `varchar(n)` counts characters — so a naive mapping can either truncate or silently relax a constraint |
| `NVARCHAR2(n)` | `varchar(n)` | PostgreSQL is Unicode throughout when the database is UTF-8 |
| `CHAR(n)` | `char(n)`, or preferably `varchar` | Oracle blank-pads `CHAR` and comparison semantics differ. Migrating to `varchar` is usually cleaner but changes trailing-space behaviour |
| `CLOB` / `NCLOB` | `text` | `text` has no practical length limit. Streaming access patterns change |
| `BLOB` | `bytea` | Note the size ceiling on `bytea` (1 GB) and the different streaming model. Very large objects may belong in S3 instead |
| `RAW(n)` | `bytea` | Fixed-length raw becomes variable-length binary; any code assuming fixed length needs checking |
| `LONG` / `LONG RAW` | `text` / `bytea` | Deprecated in Oracle too |
| `DATE` | `timestamp` (without time zone) | **Oracle `DATE` includes a time component**, so mapping it to PostgreSQL `date` loses the time. This is a classic silent data-loss error — map to `timestamp` unless the time portion is verified to be always midnight |
| `TIMESTAMP(n)` | `timestamp(n)` | |
| `TIMESTAMP WITH TIME ZONE` | `timestamptz` | Storage and normalisation semantics differ; verify round-tripping |
| `TIMESTAMP WITH LOCAL TIME ZONE` | `timestamptz` | No exact equivalent — the session-relative behaviour must be reproduced in the application |
| `INTERVAL YEAR TO MONTH` / `DAY TO SECOND` | `interval` | PostgreSQL has one unified `interval`; the two Oracle forms collapse into it |
| `XMLTYPE` | `xml` | XML function support differs; XPath usage needs review |
| `JSON` (21c+) | `jsonb` | `jsonb` is generally better; operator syntax differs entirely |
| `SDO_GEOMETRY` | PostGIS `geometry` | See Oracle Spatial above |
| `ROWID` / `UROWID` | No equivalent | Needs a surrogate key — see the SQL constructs table |
| User-defined object types | Composite types, or relational redesign | Object-relational features rarely map cleanly |
| `VARRAY` / nested tables | Arrays, or a child table | Arrays fit simple cases; nested tables usually want proper relational modelling |

**Report the mapping decisions, not just the types.** `NUMBER` → `numeric` versus `bigint`, `DATE` →
`timestamp` versus `date`, and `NUMBER(1)` → `boolean` are all judgement calls that affect application
code, and they need to be recorded as decisions the customer signs off rather than left to a tool's
default.

## 6. Data Access Layer Impact

The conversion does not stop at the database. Every place the application expresses Oracle-specific
SQL or relies on Oracle-specific behaviour is in scope, and this is routinely under-scoped because it
is not in the DDL.

| Data access technology | What changes | What to scan for |
|-----------------------|--------------|------------------|
| **Hibernate / JPA** | **Dialect change** (`Oracle12cDialect` → `PostgreSQLDialect`), sequence and identity generation strategy, LOB handling | `hibernate.dialect` in `persistence.xml` / `application.yml`; `@GeneratedValue` strategies; `@SequenceGenerator` definitions |
| **Hibernate native queries** | Oracle SQL inside `@Query(nativeQuery = true)` and `createNativeQuery` | Every native query must be reviewed individually — the dialect change does not touch them |
| **HQL / JPQL** | Mostly portable, but Oracle-specific function calls inside HQL are not | `function(`, database-specific function names in HQL strings |
| **Spring Data JPA** | Derived queries are portable; `@Query` with `nativeQuery = true` is not | Same as above |
| **MyBatis** | **Mapper XML frequently carries raw Oracle SQL** | `*Mapper.xml` files, `<selectKey>` blocks using `.NEXTVAL`, Oracle-specific `<if>` fragments, `ROWNUM` pagination |
| **Raw JDBC** | Oracle SQL in string literals, Oracle-specific driver behaviour | `PreparedStatement` / `Statement` SQL strings, `oracle.jdbc.*` imports, `OracleTypes.CURSOR`, `registerOutParameter` with Oracle types |
| **Stored procedure calls** | `CallableStatement` signatures change; Oracle `REF CURSOR` out-parameters have no PostgreSQL equivalent | `{call ...}` syntax, `OracleTypes.CURSOR`, `SimpleJdbcCall` with cursor returns. **`REF CURSOR` returns need redesign** — PostgreSQL functions return sets differently |
| **Spring `JdbcTemplate`** | SQL strings and result mapping | Query strings in Java, especially those assembled dynamically |
| **Connection pool config** | Oracle-specific validation queries and driver properties | `SELECT 1 FROM DUAL` as a validation query — a very common and easily-missed breakage. Becomes `SELECT 1` |
| **Oracle OCI / thick driver** | Native client libraries required on the host | Removing it is a **containerization win** — report it as such, since the native client is otherwise a container image dependency |
| **Reporting and BI tools** | Oracle-specific SQL in report definitions outside the application | Report definition files, BI semantic layers. Often owned by another team, so it is a coordination finding |
| **Batch and ETL** | SQL*Loader control files, external tables, ETL job SQL | See the proprietary features table |
| **Database links from other systems** | **Other applications** reading this schema directly over a database link | A cross-application coupling finding. Those consumers must be identified and coordinated with — they may be owned by teams who do not know a migration is happening |

**Empty-string handling in the data access layer.** Revisit section 3's silent behaviour change from
the application side: ORMs and JDBC code that bind an empty string, or that test for NULL on text
fields, are precisely where the difference surfaces. Report the specific call sites.

## 7. Sizing, Tooling and Cutover

### Volume inventory

Report these as inventory — they determine tooling choice and the cutover approach:

- **Total schema size** in GB, and the size of the largest tables
- **Table count**, and index count
- **Row count of the largest tables** — the tables that will dominate the load window
- **LOB volume**, which frequently dominates transfer time out of proportion to row counts
- **Number of schemas** in scope, and whether cross-schema dependencies exist
- **Daily change volume**, if determinable, since it sizes ongoing replication during a phased cutover
- **Partitioned tables** and their partition counts

### Tooling: SCT/DMS versus manual

Report the position rather than nominating a single answer; the choice depends on the inventory above.

| Approach | Where it fits | Limits to state |
|----------|---------------|-----------------|
| **AWS Schema Conversion Tool (SCT)** | Automated schema and code conversion, plus an assessment report that quantifies what it cannot convert | **SCT's own assessment report is the best available sizing evidence** — recommend running it early. It converts much PL/SQL mechanically but leaves the hard cases, and it does not find the semantic risks in section 3 |
| **AWS Database Migration Service (DMS)** | Data movement, including full load plus change data capture for minimal-downtime cutover | Handles the data; does not convert code. CDC requires supplemental logging on the Oracle side, which needs a DBA change before migration starts |
| **DMS Schema Conversion** | Managed schema conversion without running SCT locally | Same conversion limits as SCT |
| **Manual conversion** | The residue SCT cannot handle: package state, autonomous transactions, `REF CURSOR` returns, `CONNECT BY` with path functions, dynamic SQL, optimizer-hint-dependent queries | This residue is where the real effort concentrates. Size it from the SCT assessment rather than guessing |
| **`ora2pg`** | Open-source schema and code conversion with its own detailed assessment report | Useful as a cross-check against SCT's estimate |

### Cutover and the downtime window

- **Establish the acceptable downtime window** — this is a **customer-input question**, not something derivable from the code, and it determines the entire cutover approach
- **Full load only** requires a downtime window long enough for the largest tables plus validation. Simplest, and viable where a weekend window is available
- **Full load + CDC** keeps the target current while the source stays live, reducing the window to a short cutover. Requires supplemental logging and a longer preparation period
- **Phased or per-schema cutover** works where the application can be split; requires either dual-write or accepting a period of divided ownership
- **Rollback plan**: how to return to Oracle if validation fails after cutover. Report whether one is feasible — once writes have landed in PostgreSQL, going back requires reverse replication, and a plan that has no rollback should say so explicitly
- **Validation approach**: row counts, checksums, and business-level reconciliation. Note that a row-count match does not detect the empty-string or `DATE`-truncation classes of error, so reconciliation must be value-level on the columns at risk

### Performance re-validation

State this as a required workstream item rather than an afterthought:

- **Optimizer hints do not carry over** and PostgreSQL has no hint mechanism, so every hinted query is a performance-testing target
- **Execution plans will differ.** Queries that performed acceptably on Oracle may not on PostgreSQL without new indexes or rewriting
- **The statistics and maintenance model differs** — autovacuum and `ANALYZE` replace `DBMS_STATS` jobs, and getting autovacuum settings wrong on high-churn tables is a common post-migration problem
- **Connection handling differs.** PostgreSQL's per-connection process model makes connection pooling more important than on Oracle; consider RDS Proxy or PgBouncer where the application opens many connections
- Report that performance testing against production-representative data volumes is required, and that the NFRs it must be tested against are **customer input** (see `evaluation-framework.md`)

### Operational retraining

An honest finding rather than a technical one: the DBA and operations teams' Oracle expertise —
AWR/ASH analysis, RMAN, Data Guard, tablespace management — does not transfer directly. The
PostgreSQL equivalents exist (Performance Insights, `pg_stat_statements`, automated backups, PITR,
read replicas) but the workflows differ. Report this as an enablement consideration for the customer's
planning; developer and operations skill availability is a customer-input question.

## 8. Oracle Licence Elimination as a Business Driver

Removing Oracle licensing is frequently the primary driver for this workstream, and the report should
state it clearly as evidence for the customer's business case.

- Name the position: Oracle Database licensing is a **Very High** ongoing cost component, and
  Enterprise Edition with option packs (Partitioning, Advanced Compression, Diagnostics/Tuning,
  Advanced Security) compounds it. Aurora and RDS PostgreSQL carry **no engine licensing fee**
- Note where **RAC and Enterprise-only options** are in use, since those are the costliest elements and
  their removal is the largest part of the saving — while also being the features that need
  architectural workarounds, so the saving and the effort sit in the same place
- Note that licensing terms on cloud infrastructure differ from on-premises, and that the customer's
  own entitlement position and contract terms are **customer input** — do not assert what they are
  paying or what they will save
- **Qualitative only. No dollar amounts**, per the cost standards in `report-structure.md`. Use
  Low/Medium/High/Very High and state the saving potential qualitatively
- Balance it honestly: the licence saving is realised at the end of a substantial conversion
  workstream, and the report should present both together rather than the saving alone

## Validation Checklist

An Oracle → PostgreSQL workstream analysis is complete when:

1. Scope is confirmed — this file was only applied because the customer confirmed the migration is in scope
2. Oracle version, edition, RAC/topology and character set are reported
3. Every Enterprise-only feature in use is named with its PostgreSQL position and workaround, especially partitioning, RAC and materialized-view fast refresh
4. The PL/SQL inventory is quantified — procedures, functions, packages (with per-package contents), triggers, materialized views, sequences, views — plus total PL/SQL lines as inventory
5. **Package state, autonomous transactions, `REF CURSOR` returns and Java/external procedures are each flagged individually** as constructs with no PostgreSQL equivalent
6. Oracle-specific SQL constructs are inventoried across stored logic **and** application code, including dynamic SQL
7. **The empty-string-is-NULL difference is reported as a distinct high-priority silent behaviour-change risk**, with the specific affected comparisons located — not merged into the syntax table
8. `ROWNUM` ordering, `NULLS FIRST/LAST` defaults, Oracle `DATE` carrying a time component, and `VARCHAR2` byte-vs-char semantics are each called out as silent-difference risks
9. Oracle-proprietary features are mapped to targets, with AQ's transactional-semantics change and `DBMS_SCHEDULER`'s hidden batch jobs both surfaced
10. Data type mappings are reported as **decisions** requiring sign-off, not tool defaults
11. Data access layer impact covers Hibernate dialect and native queries, MyBatis mapper XML, raw JDBC, stored procedure calls, connection pool validation queries, reporting tools and external consumers reading over database links
12. Volume inventory is reported and used to position SCT/DMS versus manual conversion, with the SCT assessment report recommended as sizing evidence
13. The downtime window is named as a customer-input question, and the cutover approach, rollback feasibility and value-level validation are all addressed
14. Performance re-validation is stated as a required workstream item, with optimizer hints identified as testing targets
15. Licence elimination is reported qualitatively as a business driver, with no dollar amounts, and balanced against the conversion effort
16. Findings surface in existing report section 6 (Database Analysis & Migration Opportunity), with risks in section 4 — no new report section is introduced
