# Legacy App Modernization Analyzer

A Kiro Power that provides enterprise-grade legacy codebase modernization analysis. Generates comprehensive AWS migration feasibility reports with visual architecture diagrams, proprietary dependency analysis, and strategic migration pathways.

## Supported Modernization Paths

| Source Platform | Target Platform | Description | Status |
|-----------------|-----------------|-------------|--------|
| .NET Framework 4.x | .NET 8 + AWS | Windows-based .NET apps to cross-platform cloud-native | ✅ Stable |
| IBM WebSphere | Spring Boot Reactive + AWS | J2EE/Jakarta EE to reactive microservices | 🧪 BETA |
| Oracle WebLogic | Spring Boot Reactive + AWS | J2EE/Jakarta EE to reactive microservices | 🧪 BETA |

> **Note**: WebSphere and WebLogic modernization paths are in BETA. While functional, these paths may have limited coverage for some proprietary APIs and edge cases.

## Features

- **Auto-Detection**: Automatically identifies source platform from codebase indicators
- **Platform-Specific Analysis**: Dedicated migration strategies for each source platform
- **Comprehensive Evaluation**: 18+ modernization areas assessed
- **Visual Architecture Diagrams**: Mermaid.js diagrams with component-level color coding
- **Package License Verification**: Queries NuGet/Maven APIs for license validation
- **Proprietary Dependency Analysis**: Impact assessment with code migration examples
- **Database Migration**: SQL Server/Oracle/DB2 → Aurora PostgreSQL recommendations
- **Strategic Alignment**: AWS 7 Rs and Gartner TIME framework classification
- **Risk Assessment**: "Impact If Not Modernized" for every finding with probability ratings
- **3 Migration Pathways**: Ranked by approachability with effort breakdown
- **Cost-Benefit Analysis**: Qualitative assessments (Low/Medium/High/Very High)

## Platform Detection

The analyzer automatically detects your source platform:

### .NET Detection
- Files: `.sln`, `.csproj`, `.vbproj`, `web.config`, `packages.config`, `appsettings.json`

### WebSphere Detection
- Files: `ibm-web-bnd.xml`, `ibm-web-ext.xml`, `ibm-application-bnd.xml`, `ibm-ejb-jar-bnd.xml`
- Dependencies: `com.ibm.websphere.*`, `com.ibm.ws.*`, `com.ibm.mq.*`

### WebLogic Detection
- Files: `weblogic.xml`, `weblogic-application.xml`, `weblogic-ejb-jar.xml`
- Dependencies: `weblogic.*`, `oracle.weblogic.*`, `com.bea.*`

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
- ".NET modernization"
- "WebSphere migration"
- "WebLogic migration"
- "J2EE modernization"

### Example

```
User: analyze this codebase and generate a modernization report
```

The power will:
1. Detect source platform (.NET, WebSphere, or WebLogic)
2. Load platform-specific steering file
3. Load common framework files (evaluation, report structure, AWS services)
4. Scan codebase incrementally (context-aware for large projects)
5. Detect database technology
6. Verify package licenses via registry APIs
7. Generate `yymmddhhmm_MODERNIZATION_REPORT.md` (timestamped: YY=year, MM=month, DD=day, HH=hour, MM=minutes)

## Output

Report structure is defined by `steering/common/report-structure.md` (single source of truth):

1. **Professional Advisory Notice** - Consultation disclaimer
2. **Executive Summary** - Strategic verdict, feasibility score, risk of inaction
3. **Visual Architecture** - Current and target state diagrams (color-coded)
4. **Critical Findings Matrix** - 10+ findings with priorities
5. **Proprietary Dependency Analysis** - License verification, migration examples
6. **Database Analysis** - Detection and migration opportunity
7. **Recommended Pathways** - 3 pathways with comparison charts
8. **Next Steps** - Recommended pathway implementation roadmap
9. **Cost-Benefit Analysis** - Pathway comparison (qualitative)
10. **Solution Structure Summary** - Projects and complexity
11. **Conclusion** - Assessment and success factors

## Project Structure

```
legacy-app-modernization-analyzer/
├── POWER.md                              # Main power definition
├── mcp.json                              # MCP server configuration (fetch)
├── README.md                             # This file
└── steering/
    ├── common/                           # Shared framework (AUTHORITATIVE)
    │   ├── evaluation-framework.md       # Universal evaluation areas
    │   ├── report-structure.md           # Report format standards
    │   ├── aws-target-services.md        # AWS service mappings
    │   └── j2ee-to-springboot-reactive.md
    ├── dotnet-to-aws.md                  # .NET → .NET 8 + AWS
    ├── websphere-to-springboot.md        # WebSphere → Spring Boot
    └── weblogic-to-springboot.md         # WebLogic → Spring Boot
```

## Version History

### v2.0.0 - Legacy App Modernization Analyzer
- Multi-platform support: .NET, WebSphere, WebLogic
- Platform auto-detection
- Spring Boot Reactive target for Java platforms
- Consolidated steering files with authoritative report structure
- Expanded database support (SQL Server, Oracle, DB2)

### v1.x - .NET Modernization Analyzer
- Original .NET Framework → .NET 8 analyzer
- NuGet license verification
- Architecture diagram color coding

## License

Apache 2.0
