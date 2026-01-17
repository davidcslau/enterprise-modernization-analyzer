# .NET Modernization Analyzer Power

A Kiro Power that provides enterprise-grade .NET codebase modernization analysis, generating comprehensive feasibility reports with visual architecture diagrams, proprietary dependency analysis, database migration opportunities, and strategic alignment recommendations.

## Features

- Comprehensive evaluation across 18+ modernization areas
- Visual architecture diagrams using Mermaid.js with component-level color coding
- NuGet package license verification via NuGet.org Catalog API
- Proprietary/commercial dependency impact analysis with code migration examples
- Database detection with stored procedure count and SQL Server → Aurora PostgreSQL migration recommendations
- Migration Strategy Bank with proven patterns
- Strategic alignment with AWS 7 Rs and Gartner TIME frameworks
- "Impact If Not Modernized" risk assessments for every finding
- 3 ranked migration pathways by approachability
- Cost-benefit analysis with qualitative assessments (Low/Medium/High/Very High)
- Incremental codebase scanning for large projects (context-aware)

## What's New (Latest)

- **Architecture Diagram Color Coding**: Current and target architecture diagrams now color-code individual components by modernization risk (red=blocker, orange=concern, yellow=minor, green=modern)
- **NuGet License Verification**: Automatically queries NuGet.org Catalog API to verify SPDX license identifiers for all packages
- **Stored Procedure Analysis**: Database detection now includes total count, complexity categorization (Simple/Medium/Complex), and procedure names
- **Improved Gantt Charts**: Quick Wins timeline uses relative sequencing only (no specific dates or day/week/month durations)
- **Fixed XYChart Labels**: Cost comparison charts use abbreviated labels to prevent overlap
- **Removed Appendix Sections**: Streamlined report structure without redundant appendix content

## Key Capabilities

### Modernization Evaluation Areas

- Platform & Framework (target version, Windows-only dependencies)
- Architecture (monolithic vs modular, layering violations)
- Dependencies (proprietary library compatibility, NuGet CVEs, license blocks)
- Code Quality (cyclomatic complexity, maintainability)
- Design Patterns (DI usage vs Service Locator)
- Data Layer (ORM type, stored procedures, N+1 queries)
- Performance (async/await usage, caching strategies)
- Testing (coverage, integration tests)
- Security (auth patterns)
- UI Layer (WinForms/WebForms vs modern frameworks)
- DevOps (CI/CD maturity, container readiness)
- Observability (structured logging, tracing)
- Documentation quality
- Business Logic (domain isolation)
- Infrastructure (on-premises vs cloud-native)
- Skills/Org (code complexity vs team capability)
- Support Lifecycle (EOL status)
- Legacy Antipatterns (global state, ThreadPool exhaustion)

### Database Detection & Migration (Critical Feature)

The power automatically scans for database technology and prominently recommends cost optimization opportunities:

- Detects SQL Server indicators (connection strings, SqlClient, T-SQL patterns)
- **Counts and categorizes stored procedures** (Simple/Medium/Complex)
- Identifies SQL Server-specific features (T-SQL functions, data types)
- Recommends SQL Server → Aurora PostgreSQL migration path
- Provides T-SQL to PostgreSQL conversion examples
- Highlights database licensing as primary cost driver
- References AWS SCT and DMS migration tools

### NuGet License Verification

Automatically verifies package licenses from NuGet.org:

- Queries NuGet Registration API for package metadata
- Extracts `licenseExpression` SPDX identifiers from Catalog API
- Adds verification note to Proprietary Dependency Analysis section
- Flags license risks (MIT=Low, Proprietary=High)

### Cost-Benefit Analysis

Uses qualitative terms for flexibility:

- Cost levels: Low / Medium / High / Very High
- Savings potential: Low / Medium / High / Very High
- Effort complexity: Low / Medium / High
- No specific dollar amounts or timeframes
- XYChart with abbreviated labels to prevent overlap

## Installation

1. Open Kiro IDE
2. Go to the Powers panel
3. Search for ".NET Modernization Analyzer" or install from GitHub
4. Enter this repository URL: `https://github.com/davidcslau/dotnet-modernization-analyzer`

## Prerequisites

- Kiro IDE
- `uvx` installed (for the fetch MCP server used in NuGet license verification)
  - Install via: `pip install uv` or see [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/)

## Usage

Activate the power by mentioning any of these phrases:

- "analyze this .NET codebase"
- "modernization assessment"
- "migration feasibility"
- "legacy .NET application"
- "AWS migration for .NET"
- "containerize .NET app"
- "modernize to .NET Core/.NET 8"
- "evaluate modernization pathways"
- "proprietary dependency analysis"

### Example

```
User: analyze this codebase and generate me its modernization report
```

The power will automatically:

1. Scan codebase structure (incrementally for large codebases)
2. Detect database technology and count stored procedures
3. Verify NuGet package licenses via NuGet.org API
4. Evaluate all modernization areas
5. Identify proprietary dependencies with migration examples
6. Generate visual architecture diagrams with color-coded components
7. Assess SQL Server → PostgreSQL migration opportunity
8. Create `MODERNIZATION_REPORT.md` with pathways and recommendations

## Output Structure

The generated `MODERNIZATION_REPORT.md` includes:

1. **Executive Summary** - Strategic verdict, risk of inaction, feasibility score
2. **Visual Architecture State** - Color-coded current and target architecture diagrams
3. **Critical Findings Matrix** - All findings with priorities and impact assessment
4. **Proprietary Dependency Analysis** - License verification, compatibility, migration examples
5. **Database Analysis & Migration Opportunity** - Stored procedure count, T-SQL conversion guide
6. **Recommended Pathways** - 3 pathways ranked by approachability with flowcharts
7. **Next Steps** - Quick wins with relative timeline, strategic initiatives
8. **Cost-Benefit Analysis** - XYChart comparison, ROI summary

## Power Structure

```
dotnet-modernization-analyzer/
├── POWER.md                    # Main power definition
├── mcp.json                    # MCP server configuration (fetch)
├── README.md                   # This file
└── .kiro/steering/             # Steering files
    └── building-kiro-powers.md # Power development guide
```

## License

MIT
