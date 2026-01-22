# Legacy App Modernization Analyzer

A Kiro Power that provides enterprise-grade legacy codebase modernization analysis. Generates comprehensive AWS migration feasibility reports with visual architecture diagrams, proprietary dependency analysis, and strategic migration pathways.

## Supported Modernization Paths

| Source Platform | Target Platform | Description |
|-----------------|-----------------|-------------|
| .NET Framework 4.x | .NET 8 + AWS | Windows-based .NET apps to cross-platform cloud-native |
| IBM WebSphere | Spring Boot Reactive + AWS | J2EE/Jakarta EE to reactive microservices |
| Oracle WebLogic | Spring Boot Reactive + AWS | J2EE/Jakarta EE to reactive microservices |

## Features

- **Auto-Detection**: Automatically identifies source platform from codebase indicators
- **Platform-Specific Analysis**: Dedicated migration strategies for each source platform
- **Comprehensive Evaluation**: 18+ modernization areas assessed
- **Visual Architecture Diagrams**: Mermaid.js diagrams with component-level color coding
- **Package License Verification**: Queries NuGet/Maven APIs for license validation
- **Proprietary Dependency Analysis**: Impact assessment with code migration examples
- **Database Migration**: SQL Server/Oracle/DB2 → Aurora PostgreSQL recommendations
- **Strategic Alignment**: AWS 7 Rs and Gartner TIME framework classification
- **Risk Assessment**: "Impact If Not Modernized" for every finding
- **3 Migration Pathways**: Ranked by approachability with effort estimates
- **Cost-Benefit Analysis**: Qualitative assessments (Low/Medium/High/Very High)

## Platform Detection

The analyzer automatically detects your source platform:

### .NET Detection
- Files: `.sln`, `.csproj`, `.vbproj`, `web.config`, `packages.config`

### WebSphere Detection
- Files: `ibm-web-bnd.xml`, `ibm-web-ext.xml`, `ibm-application-bnd.xml`
- Dependencies: `com.ibm.websphere.*`, `com.ibm.ws.*`, `com.ibm.mq.*`

### WebLogic Detection
- Files: `weblogic.xml`, `weblogic-application.xml`, `weblogic-ejb-jar.xml`
- Dependencies: `weblogic.*`, `oracle.weblogic.*`, `com.bea.*`

## Installation

1. Open Kiro IDE
2. Go to the Powers panel
3. Install from GitHub: `https://github.com/kiro-community/powers/legacy-app-modernization-analyzer`

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
- ".NET modernization"
- "WebSphere migration"
- "WebLogic migration"
- "J2EE modernization"
- "modernize to Spring Boot"

### Example

```
User: analyze this codebase and generate a modernization report
```

The power will:
1. Detect source platform (.NET, WebSphere, or WebLogic)
2. Load platform-specific steering file
3. Scan codebase incrementally (context-aware for large projects)
4. Detect database technology
5. Verify package licenses via registry APIs
6. Evaluate all modernization areas
7. Generate `MODERNIZATION_REPORT.md`

## Output

The generated `MODERNIZATION_REPORT.md` includes:

1. **Executive Summary** - Strategic verdict, feasibility score, risk of inaction
2. **Visual Architecture** - Current and target state diagrams (color-coded)
3. **Critical Findings Matrix** - All findings with priorities and impact
4. **Proprietary Dependency Analysis** - License verification, compatibility, migration examples
5. **Recommended Pathways** - 3 pathways with flowcharts and effort tables
6. **Next Steps** - Quick wins roadmap, strategic initiatives
7. **Cost-Benefit Analysis** - Comparison charts, ROI summary
8. **Professional Advisory Notice** - Consultation disclaimer

## Project Structure

```
legacy-app-modernization-analyzer/
├── POWER.md                              # Main power definition
├── mcp.json                              # MCP server configuration
├── README.md                             # This file
└── steering/
    ├── common/                           # Shared evaluation framework
    │   ├── evaluation-framework.md
    │   ├── report-structure.md
    │   ├── aws-target-services.md
    │   └── j2ee-to-springboot-reactive.md  # J2EE → Spring Boot Reactive patterns
    ├── dotnet-to-aws.md                  # .NET → .NET 8 + AWS
    ├── websphere-to-springboot.md        # WebSphere → Spring Boot
    └── weblogic-to-springboot.md         # WebLogic → Spring Boot
```

## Version History

### v2.0.0 - Legacy App Modernization Analyzer
- Multi-platform support: .NET, WebSphere, WebLogic
- Platform auto-detection
- Spring Boot Reactive target for Java platforms
- Platform-specific steering files
- Expanded database support (SQL Server, Oracle, DB2)

### v1.x - .NET Modernization Analyzer
- Original .NET Framework → .NET 8 analyzer
- NuGet license verification
- Architecture diagram color coding
- Stored procedure analysis

## License

Apache 2.0
