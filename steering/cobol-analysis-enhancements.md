---
inclusion: manual
---

# COBOL Mainframe Analysis Enhancements

This steering file supplements `cobol-to-java.md` and `report-structure.md` with enhancements derived from real-world analysis sessions. Load this file alongside those two when performing COBOL mainframe modernization analysis.

Note: Mermaid diagram contrast rules (`,color:#000` on every style line) are defined in `report-structure.md` since they apply to all platform analyses, not just COBOL.

---

## ENHANCEMENT 1: Mechanical Data Inventory Extraction

### Problem
Reading COBOL files one-by-one and hoping to spot all data structures produces incomplete inventories. Copybooks get missed, VSAM files get undercounted, DB2 tables get partially documented, and data type mappings are incomplete.

### Rule
**Use targeted regex searches across the entire codebase FIRST, then read specific files only for detail.** Every inventory must be cross-referenced against at least two independent sources (e.g., CSD + LISTCAT for VSAM, DDL + DCL for DB2).

### Step-by-Step Extraction Procedure

#### 2A. VSAM File Inventory (must match CSD + LISTCAT + program usage)

**Source 1 — CSD file definitions (authoritative list of CICS-accessible files):**
```
grepSearch: query="DEFINE FILE" includePattern="**/*.csd"
```
Parse each result for: file name, DSNAME, ADD/BROWSE/DELETE/READ/UPDATE permissions.

**Source 2 — LISTCAT (authoritative VSAM cluster metadata):**
```
grepSearch: query="CLUSTER|KEYLEN|AVGLRECL|MAXLRECL|REC-TOTAL" includePattern="**/LISTCAT*"
```
Parse for: cluster name, key length, record length, record count, KSDS/ESDS/RRDS type.

**Source 3 — AIX and PATH definitions:**
```
grepSearch: query="^0AIX|^0PATH" includePattern="**/LISTCAT*"
```

**Cross-reference — which programs access which files:**
```
grepSearch: query="DATASET|FILE" includePattern="**/*.cbl"
```

**Completeness check:** The number of DEFINE FILE entries in CSD must match the number of VSAM clusters in LISTCAT (excluding non-VSAM datasets). Every file in CSD must appear in at least one program's EXEC CICS READ/WRITE/etc.

**Output table (REQUIRED in report):**

| CICS File | VSAM Dataset | Type | Key Len | Rec Len | Records | Programs | PostgreSQL Target |
|-----------|-------------|------|---------|---------|---------|----------|-------------------|

#### 2B. Batch Data File Inventory

**Scan data directories:**
```
listDirectory: path="app/data" depth=2
```

**Cross-reference with JCL DD statements:**
```
grepSearch: query="DD.*DSN=" includePattern="**/*.jcl"
```

**Match to copybook record layouts** by correlating dataset name suffixes to copybook names (e.g., `ACCTDATA` → `CVACT01Y.cpy`).

**Output table (REQUIRED in report):**

| File Name | Format | Record Layout Copybook | Record Length | JCL Jobs | PostgreSQL Target |
|-----------|--------|----------------------|---------------|----------|-------------------|

#### 2C. DB2 Table Inventory (must match DDL + DCL + program SQL)

**Source 1 — DDL (authoritative schema):**
```
grepSearch: query="CREATE TABLE" includePattern="**/*.ddl"
```
Read each DDL file fully. Parse: table name, all columns with types, PRIMARY KEY, FOREIGN KEY.

**Source 2 — DCL (COBOL declarations):**
```
grepSearch: query="EXEC SQL DECLARE.*TABLE" includePattern="**/*.dcl"
```
Read each DCL file fully. Parse the COBOL 01-level structure for PIC clauses.

**Source 3 — Embedded SQL in programs:**
```
grepSearch: query="EXEC SQL" includePattern="**/*.cbl"
```
For each match: program name, SQL verb (SELECT/INSERT/UPDATE/DELETE), table name.

**Source 4 — SQL INCLUDE statements:**
```
grepSearch: query="EXEC SQL.*INCLUDE" includePattern="**/*.cbl"
```

**Completeness check:** Every table in DDL must have a matching DCL. Every table referenced in program SQL must appear in DDL. Every DCL INCLUDE in a program must resolve to an existing DCL file.

**Output table (REQUIRED in report):**

| Table | Columns | Primary Key | Foreign Keys | DDL File | Programs | SQL Operations |
|-------|---------|-------------|-------------|----------|----------|----------------|

#### 2D. IMS Database Inventory

```
fileSearch: query="*.dbd"
fileSearch: query="*.psb"
grepSearch: query="CBLTDLI|AIBTDLI" includePattern="**/*.cbl"
```

#### 2E. MQ Queue Inventory

```
grepSearch: query="MQGET|MQPUT|MQPUT1|MQOPEN|MQCLOSE" includePattern="**/*.cbl"
grepSearch: query="MQTM-QNAME|QUEUE-NAME|MQ-QUEUE|REPLY-QUEUE|ERROR-QUEUE" includePattern="**/*.cbl"
```

#### 2F. Exhaustive Copybook Data Type Mapping

**Step 1 — List ALL copybooks:**
```
listDirectory: path="app/cpy"
```
Plus every sub-application `cpy` directory.

**Step 2 — Read EVERY copybook.** Do not skip any. For each `.cpy` file, extract:
- 01-level record name
- Every 05/10-level field with its PIC clause
- Every 88-level condition name with its VALUES
- Every REDEFINES
- Record length (from comment or field sum)

**Step 3 — Map EVERY field** using this conversion table:

| PIC Pattern | PostgreSQL | Java | Notes |
|-------------|-----------|------|-------|
| `X(n)` | VARCHAR(n) | String | |
| `9(1-4)` | SMALLINT | int | |
| `9(5-9)` | INTEGER | int | |
| `9(10-18)` | BIGINT | long | |
| `S9(n)V9(m)` | NUMERIC(n+m,m) | BigDecimal | Financial — CRITICAL |
| `S9(n)V99` | NUMERIC(n+2,2) | BigDecimal | Most common financial |
| `S9(n) COMP` | INTEGER/BIGINT | int/long | Binary storage |
| `S9(n) COMP-3` | NUMERIC | BigDecimal | Packed decimal |
| `X(10)` with DATE in name | DATE | LocalDate | |
| `X(26)` with TS in name | TIMESTAMP | Instant | |

**Step 4 — Cross-reference copybooks to programs:**
```
grepSearch: query="COPY " includePattern="**/*.cbl"
```

**Completeness check:** Every copybook in every `cpy` directory must appear in the data type mapping tables. Every copybook referenced by a COPY statement in a program must be documented.

**Output (REQUIRED in report):** One data type mapping table PER copybook, showing every field. Group by copybook with the copybook name and record length as the table header.

#### 2G. CICS Transaction Inventory (must match CSD + menu copybooks + program analysis)

**Source 1 — CSD transaction definitions:**
```
grepSearch: query="DEFINE TRANSACTION" includePattern="**/*.csd"
```
Parse: transaction ID, program name, description.

**Source 2 — CSD program definitions:**
```
grepSearch: query="DEFINE PROGRAM" includePattern="**/*.csd"
```

**Source 3 — Menu option copybooks:**
```
grepSearch: query="CDEMO-MENU-OPT|CDEMO-ADMIN-OPT" includePattern="**/*.cpy"
```
Read the full menu definition copybooks to get option number, name, program, user type.

**Source 4 — BMS mapset definitions:**
```
grepSearch: query="DEFINE MAPSET" includePattern="**/*.csd"
```

**Completeness check:** Every DEFINE TRANSACTION must map to a DEFINE PROGRAM. Every menu option program must appear in DEFINE PROGRAM. Every program with SEND MAP must have a matching DEFINE MAPSET.

**Output tables (REQUIRED in report):**
1. Online Transactions table: Trans ID | Program | Function | REST API Target
2. Regular User Menu Options table (from menu copybook): # | Option | Program | Access Level
3. Admin Menu Options table (from admin copybook): # | Option | Program
4. Batch Programs table: Program | Function | Migration Target
5. Sub-Application Programs table: Program | Sub-App | Function

---

## ENHANCEMENT 2: Mechanical Business Rule Extraction

### Problem
The existing `cobol-to-java.md` Business Logic Extraction Framework defines 10 categories and says "look for X" but does not specify HOW to mechanically find the rules. Reading programs file-by-file is slow, incomplete, and non-repeatable. The result is a business logic section with 15-40 rules when the actual codebase contains 80-100+.

### Rule
**Use codebase-wide grep searches to find ALL instances of each pattern FIRST, then read surrounding context only where needed.** Each category has specific regex patterns that mechanically extract every rule.

### Step-by-Step Extraction Procedure

#### 3A. Input Validation Rules

**Search 1 — Required field checks:**
```
grepSearch: query="= SPACES|= LOW-VALUES|= ZEROS" includePattern="**/*.cbl"
```
Every match where a field is compared to SPACES/LOW-VALUES/ZEROS inside an IF or EVALUATE is a required-field validation. Capture the field name, the error message on the next few lines, and the paragraph name.

**Search 2 — Numeric validation:**
```
grepSearch: query="IS NOT NUMERIC|IS NUMERIC" includePattern="**/*.cbl"
```

**Search 3 — 88-level validation flags (the validation state machine):**
```
grepSearch: query="88.*FLG-.*VALUE" includePattern="**/*.cbl"
```
These define the validation flag states. Each flag triplet (ISVALID/NOT-OK/BLANK) represents one validation rule.

**Search 4 — Range/list validations in copybooks:**
```
grepSearch: query="VALUES.*THRU|88.*VALUES '" includePattern="**/*.cpy"
```
These define valid value ranges (e.g., year 1950-2099, Y/N flags, NANPA area codes).

**Search 5 — EVALUATE TRUE validation blocks:**
```
grepSearch: query="EVALUATE TRUE" includePattern="**/*.cbl"
```
Each EVALUATE TRUE block is a validation decision tree. Read 30-50 lines of context around each match to capture all WHEN clauses.

**Search 6 — Error messages (confirms what validations exist):**
```
grepSearch: query="MOVE '.*' TO WS-MESSAGE|MOVE '.*' TO WS-RETURN-MSG" includePattern="**/*.cbl"
```
Every error message literal confirms a validation rule exists. Work backwards from the message to find the condition.

**Completeness check:** The number of validation rules must be >= the number of distinct error message literals found in Search 6. If you have fewer rules than messages, you missed some.

#### 3B. Calculation and Processing Rules

**Search 1 — All arithmetic:**
```
grepSearch: query="COMPUTE |ADD .* TO |SUBTRACT .* FROM |MULTIPLY .* BY |DIVIDE .* BY " includePattern="**/*.cbl"
```

**Search 2 — Financial field operations (CRITICAL — these are the highest-risk rules):**
```
grepSearch: query="CURR-BAL|CREDIT-LIMIT|TRAN-AMT|INT-RATE|CAT-BAL|PAGE-TOTAL|GRAND-TOTAL|ACCOUNT-TOTAL|APPROVED-AMT|TRANSACTION-AMT" includePattern="**/*.cbl"
```
Any arithmetic involving these fields is a critical financial calculation that must use BigDecimal in Java.

**Search 3 — FUNCTION calls:**
```
grepSearch: query="FUNCTION " includePattern="**/*.cbl"
```
Captures: CURRENT-DATE, UPPER-CASE, NUMVAL, INTEGER-OF-DATE, LENGTH, TRIM, TEST-NUMVAL.

**Search 4 — STRING/UNSTRING/INSPECT:**
```
grepSearch: query="STRING |UNSTRING |INSPECT " includePattern="**/*.cbl"
```

**Search 5 — Report formatting (PIC edit masks):**
```
grepSearch: query="PIC .*Z.*\\.|PIC \\+|PIC -" includePattern="**/*.cbl"
```
These are display formatting rules (e.g., `PIC -ZZZ,ZZZ,ZZZ.ZZ`).

**Completeness check:** Every COMPUTE/ADD/SUBTRACT/MULTIPLY/DIVIDE match from Search 1 must appear as a rule in the output. No arithmetic operation should be undocumented.

#### 3C. Decision and Routing Rules

**Search 1 — XCTL (transfer control):**
```
grepSearch: query="XCTL PROGRAM" includePattern="**/*.cbl"
```
For each match, read surrounding context to find the IF/EVALUATE condition that triggers the transfer.

**Search 2 — LINK calls:**
```
grepSearch: query="EXEC CICS LINK" includePattern="**/*.cbl"
```

**Search 3 — PF key handling:**
```
grepSearch: query="EIBAID|DFHENTER|DFHPF" includePattern="**/*.cbl"
```

**Search 4 — User type routing:**
```
grepSearch: query="USRTYP-ADMIN|USRTYP-USER|USR-TYPE" includePattern="**/*.cbl"
```

**Search 5 — Menu option tables (the complete routing map):**
```
grepSearch: query="OPT-PGMNAME|OPT-NAME|OPT-COUNT" includePattern="**/*.cpy"
```
Read the full menu copybooks (COMEN02Y, COADM02Y or equivalent) to get every option-to-program mapping.

**Completeness check:** Every XCTL PROGRAM match must appear as a routing rule. Every menu option must appear. Every PF key handler must be documented.

#### 3D. Data Access Rules

**Search 1 — ALL CICS file I/O:**
```
grepSearch: query="EXEC CICS (READ|WRITE|REWRITE|DELETE|STARTBR|READNEXT|READPREV|ENDBR)" includePattern="**/*.cbl"
```
For each match, capture: operation, DATASET/FILE name, RIDFLD (key), UPDATE keyword, INTO/FROM variable.

**Search 2 — ALL DB2 SQL:**
```
grepSearch: query="EXEC SQL" includePattern="**/*.cbl"
```
For each non-INCLUDE match: SQL verb, table name, WHERE clause, cursor name.

**Search 3 — ALL MQ operations:**
```
grepSearch: query="CALL 'MQ" includePattern="**/*.cbl"
```

**Search 4 — TD/TS queue operations:**
```
grepSearch: query="WRITEQ TD|READQ TD|WRITEQ TS|READQ TS" includePattern="**/*.cbl"
```

**Search 5 — Batch file I/O (non-CICS programs):**
```
grepSearch: query="OPEN |CLOSE |READ |WRITE " includePattern="**/CB*.cbl"
```

**Completeness check:** Every VSAM file in the CSD must appear in at least one DA rule. Every DB2 table in the DDL must appear. Every MQ queue must appear. The total DA rule count should be significantly higher than the number of unique files/tables — because each program that accesses a file generates separate rules.

#### 3E. Security and Authorization Rules

```
grepSearch: query="USR-PWD|PASSWORD|PASSWD" includePattern="**/*.cbl"
grepSearch: query="USRTYP|USR-TYPE|USER-TYPE" includePattern="**/*.cbl"
grepSearch: query="CDEMO-USER-ID|CDEMO-FROM-PROGRAM|CDEMO-TO-PROGRAM" includePattern="**/*.cbl"
grepSearch: query="RESSEC|CMDSEC" includePattern="**/*.csd"
```

#### 3F. Error Handling Rules

**Search 1 — CICS RESP handling:**
```
grepSearch: query="RESP\\(|DFHRESP" includePattern="**/*.cbl"
```

**Search 2 — Error message literals (EXHAUSTIVE — captures every user-facing message):**
```
grepSearch: query="MOVE '.*' TO WS-MESSAGE|MOVE '.*' TO WS-RETURN-MSG|MOVE '.*' TO ERRMSGO" includePattern="**/*.cbl"
```

**Search 3 — 88-level error messages (captures messages defined as condition names):**
```
grepSearch: query="88.*VALUE$" includePattern="**/*.cbl"
```
Read surrounding context — these are often message constants like `88 DID-NOT-FIND-ACCT VALUE 'Did not find...'`.

**Search 4 — ABEND handling:**
```
grepSearch: query="HANDLE ABEND|ABEND-CODE" includePattern="**/*.cbl"
```

**Search 5 — DB2 SQLCODE:**
```
grepSearch: query="SQLCODE|SQLCA" includePattern="**/*.cbl"
```

**Search 6 — MQ errors:**
```
grepSearch: query="MQ-REASON-CODE|MQ-CONDITION-CODE|MQRC-" includePattern="**/*.cbl"
```

**Search 7 — Batch file status:**
```
grepSearch: query="FILE-STATUS|STATUS = '00'|STATUS NOT" includePattern="**/*.cbl"
```

**Completeness check:** Every error message literal from Search 2 and Search 3 must appear as an EH rule. The total error handling rule count should be >= the number of distinct error messages found.

#### 3G. Batch Processing Rules

```
grepSearch: query="EXEC PGM=" includePattern="**/*.jcl"
grepSearch: query="DD.*DSN=" includePattern="**/*.jcl"
grepSearch: query="SORT|MERGE|DFSORT" includePattern="**/*.jcl"
grepSearch: query="TRIGGERED JOBS|JOB=" includePattern="**/*.ca7"
```
Read scheduler files fully to build the complete job dependency chain.

### Expected Rule Counts

For a typical COBOL/CICS application of CardDemo's size (~40 programs, ~30 copybooks, ~40 JCL jobs):

| Category | Expected Minimum | If Below, You Missed Something |
|----------|-----------------|-------------------------------|
| Input Validation | 25-40 | Check: did you scan EVERY program's EVALUATE TRUE blocks? |
| Calculation/Processing | 10-20 | Check: did you find ALL COMPUTE/ADD/SUBTRACT? All financial fields? |
| Decision/Routing | 5-15 | Check: did you read ALL menu copybooks? All XCTL calls? |
| Data Access | 25-40 | Check: did you cover ALL VSAM files × ALL programs? All DB2 SQL? |
| Security | 3-8 | Check: did you find password handling, user type checks, COMMAREA session? |
| Error Handling | 10-25 | Check: did you capture ALL error message literals? |
| **Total** | **80-150** | If total < 80, the extraction is incomplete |

---

## ENHANCEMENT 3: Report Section Additions

### Problem
The existing `report-structure.md` does not include a Business Logic section or a complete CICS Transaction Inventory section. These are critical for COBOL modernization reports.

### Rule
For COBOL mainframe reports, add these sections BETWEEN the Database Analysis section and the Recommended Pathways section:

#### Additional Section: Complete CICS Transaction and Program Inventory

This section must include ALL of the following tables:

1. **Online Transactions** (from CSD DEFINE TRANSACTION): Trans ID | Program | Function | REST API Target
2. **Regular User Menu Options** (from menu copybook): # | Option Name | Program | Access Level
3. **Admin Menu Options** (from admin copybook): # | Option Name | Program
4. **Batch Programs** (all CB* prefix programs): Program | Function | Spring Batch Target
5. **Sub-Application Programs** (programs in sub-app directories): Program | Sub-App | Function

#### Additional Section: Business Logic Extraction

This section must include ALL of the following:

1. **Input Validation Rules table** — every VR-nnn rule found via Enhancement 3A searches
2. **Calculation/Processing Rules table** — every PR-nnn rule found via Enhancement 3B searches
3. **Decision/Routing Rules table** — every DR-nnn rule found via Enhancement 3C searches
4. **Data Access Rules table** — every DA-nnn rule found via Enhancement 3D searches
5. **Security Rules table** — every SEC-nnn rule found via Enhancement 3E searches
6. **Error Handling Rules table** — every EH-nnn rule found via Enhancement 3F searches
7. **Business Logic Summary table** — aggregated counts by category and criticality
8. **Business Logic Dependency Map** — Mermaid diagram showing cross-program rule dependencies (with `color:#000` on all style lines)

---

## ENHANCEMENT 4: Cross-Reference Validation (Final Quality Gate)

Before finalizing the report, run these validation checks:

### 5A. Copybook-to-Program Matrix
```
grepSearch: query="COPY " includePattern="**/*.cbl"
```
Verify: every copybook in every `cpy` directory is referenced by at least one program. Any unreferenced copybook is dead code — note it in the report.

### 5B. File-to-Program Matrix
From the DA rules, verify: every VSAM file in the CSD is accessed by at least one program. Every DB2 table in the DDL is accessed by at least one program.

### 5C. Transaction-to-Program Matrix
From the CSD, verify: every DEFINE TRANSACTION maps to a DEFINE PROGRAM. Every menu option program exists as a DEFINE PROGRAM.

### 5D. Data Type Mapping Completeness
Verify: every `.cpy` file has a corresponding data type mapping table in the report. Count the total fields mapped — for CardDemo-sized apps, expect 80-120+ fields across all copybooks.

### 5E. Business Rule Count Validation
Verify against the Expected Rule Counts table in Enhancement 3. If any category is below the minimum, go back and re-run the searches for that category.
