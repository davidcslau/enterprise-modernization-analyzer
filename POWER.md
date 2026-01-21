---
name: "legacy-app-modernization-analyzer"
displayName: "Legacy App Modernization Analyzer"
description: "Analyzes legacy enterprise codebases (.NET, WebSphere, WebLogic) and generates comprehensive AWS modernization feasibility reports with visual architecture diagrams, dependency analysis, and migration pathways"
keywords: [".NET", "WebSphere", "WebLogic", "Spring Boot", "modernization", "migration", "legacy", "AWS", "containerization", "microservices", "J2EE", "Jakarta", "reactive"]
version: "2.0"
---

# Legacy App Modernization Analyzer

## Overview

This power provides elite-level enterprise architecture analysis for legacy application modernization projects. It supports multiple source platforms and generates comprehensive feasibility reports with visual diagrams, following a rigorous evaluation framework and migration strategy bank.

## Supported Modernization Paths

| Source Platform | Target Platform | Steering File |
|-----------------|-----------------|---------------|
| .NET Framework 4.x | .NET 8 + AWS | `steering/dotnet-to-aws.md` |
| IBM WebSphere | Spring Boot Reactive + AWS | `steering/websphere-to-springboot.md` |
| Oracle WebLogic | Spring Boot Reactive + AWS | `steering/weblogic-to-springboot.md` |

## Workflow Routing

### Step 1: Platform Detection

Scan the codebase to identify the source platform:

**Detect .NET:**
- Look for: `.sln`, `.csproj`, `.vbproj`, `web.config`, `packages.config`, `appsettings.json`
- If found → Load `steering/dotnet-to-aws.md`

**Detect WebSphere:**
- Look for: `ibm-web-bnd.xml`, `ibm-web-ext.xml`, `ibm-application-bnd.xml`, `ibm-ejb-jar-bnd.xml`
- JAR dependencies: `com.ibm.websphere.*`, `com.ibm.ws.*`, `com.ibm.mq.*`
- If found → Load `steering/websphere-to-springboot.md`

**Detect WebLogic:**
- Look for: `weblogic.xml`, `weblogic-application.xml`, `weblogic-ejb-jar.xml`
- JAR dependencies: `weblogic.*`, `oracle.weblogic.*`, `com.bea.*`
- If found → Load `steering/weblogic-to-springboot.md`

### Step 2: Load Common Framework

ALWAYS load these steering files for any analysis:
- `steering/evaluation-framework.md` - Universal evaluation areas
- `steering/report-structure.md` - Report format standards
- `steering/aws-target-services.md` - AWS service mappings

### Step 3: Execute Platform-Specific Analysis

Follow the loaded platform steering file for:
- Technology-specific detection patterns
- Migration strategy bank
- Code transformation examples
- Platform-specific risks and mitigations

## CRITICAL DIRECTIVES

YOU MUST FOLLOW THESE DIRECTIVES FOR EVERY ANALYSIS:

### 1. EXHAUSTIVE ANALYSIS MODE

Generate the most detailed, comprehensive report possible. Assume the user demands extreme depth - this is $1M/project consulting-grade work.

### 2. INCREMENTAL CODEBASE SCANNING

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

### 3. VISUALIZATION MANDATE

BIAS HEAVILY towards Mermaid.js visualizations:
- Architecture diagrams (current state AND target state)
- Dependency graphs showing project relationships
- Quadrant charts for pathway comparison
- Flowcharts for migration phases
- Gantt-style diagrams for quick wins
- XY charts for cost comparisons
- STRICTLY FORBID ASCII art
- DO NOT use pie charts for effort distribution - use tables instead

### 4. PROPRIETARY DEPENDENCY DEEP DIVE

For EVERY proprietary/commercial library found:
- Detailed compatibility assessment table
- Code migration examples (before/after)
- Specific mitigation options with effort levels

### 5. COST-BENEFIT ANALYSIS

ALWAYS include infrastructure cost projections with:
- Current vs modernized cost comparison (Low/Medium/High/Very High)
- ROI summary (qualitative impact levels)
- Savings potential assessment
- Database licensing as primary cost driver (when applicable)

### 6. RISK OF INACTION

For EVERY finding, articulate specific business consequences if not modernized.

### 7. DATABASE DETECTION & MIGRATION ANALYSIS

Scan the codebase to identify database technology:
- SQL Server indicators: connection strings, `SqlConnection`, `SqlCommand`
- Oracle indicators: `Oracle.DataAccess`, `Oracle.ManagedDataAccess`
- DB2 indicators: `IBM.Data.DB2`
- If commercial database detected, prominently recommend Aurora PostgreSQL for cost optimization

## Bundled MCP Server

This power includes the `fetch` MCP server (configured in `mcp-config.json`) to query package registry APIs for license verification.

**Note**: Ensure `uvx` is installed (via `uv` Python package manager). See [uv installation guide](https://docs.astral.sh/uv/getting-started/installation/).

## Prerequisites

- Access to codebase (local or repository)
- Familiarity with source platform (.NET, WebSphere, or WebLogic)
- Understanding of modernization goals (cloud-native, containerization, etc.)
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
- ".NET modernization"
- "WebSphere migration"
- "WebLogic migration"
- "J2EE modernization"

## MANDATORY REQUIREMENTS

### 1. OUTPUT FILE

Generate report in `MODERNIZATION_REPORT.md`

### 2. PROFESSIONAL ADVISORY NOTICE

The report MUST include this EXACT notice at the very end:

> 📋 **Professional Advisory Notice**: This report provides a high-level technical analysis based on automated codebase scanning and should be interpreted in consultation with AWS Modernization Specialists or authorized AWS Modernization Partners. The findings and recommendations herein are intended to inform strategic planning discussions and should not be acted upon directly without professional guidance. Implementation effectiveness is influenced by numerous factors that cannot be extracted from the codebase alone, including organizational readiness, team dynamics, business constraints, regulatory requirements, and market conditions. We recommend engaging with qualified modernization experts to develop a comprehensive implementation strategy tailored to your specific organizational context.

### 3. EXHAUSTIVE DETAIL

Generate the MOST comprehensive report possible. Include:
- Every evaluation area with specific findings
- All proprietary dependencies with detailed analysis
- Multiple Mermaid diagrams
- Code migration examples
- Cost-benefit analysis

### 4. VISUALIZATION HEAVY

Include AT MINIMUM:
- Current state architecture diagram
- Target state architecture diagram
- Pathway comparison quadrant chart
- Phase flowcharts for each pathway
- Quick wins gantt diagram
- Cost comparison chart
- Dependency graph
- NO ASCII ART EVER

### 5. PROPRIETARY DEPENDENCY MANDATE

For EACH proprietary/commercial library:
- Full compatibility table
- Detailed analysis section with code examples
- Mitigation options table

### 6. RISK OF INACTION

For EVERY finding, articulate specific business consequences if not modernized.

### 7. STRATEGIC ALIGNMENT

Classify using both:
- AWS 7 Rs (Rehost, Replatform, Refactor, Repurchase, Retire, Retain, Relocate)
- Gartner TIME (Tolerate, Invest, Migrate, Eliminate)

### 8. COST ANALYSIS

Include infrastructure cost projections with:
- Current vs modernized cost levels (Low/Medium/High/Very High)
- Savings potential assessment
- ROI summary using qualitative terms
- Database licensing as primary cost driver

## REPORT STRUCTURE

Follow this exact structure:
1. Executive Summary (Strategic Verdict table, Key Findings table, Risk of Inaction table)
2. Visual Architecture State (Current + Target diagrams)
3. Critical Findings Matrix (detailed table with Impact If Not Modernized column)
4. Proprietary Dependency Analysis (comprehensive tables + code examples)
5. Recommended Pathways (3 pathways with quadrant chart, flowcharts, effort tables)
6. Next Steps (gantt diagram, action tables, tool recommendations)
7. Cost-Benefit Analysis (cost table, ROI)
8. Professional Advisory Notice (MUST include the exact hardcoded notice)

## Quality Checklist

Before completing the report, verify:

- [ ] Platform correctly detected (.NET, WebSphere, or WebLogic)
- [ ] Correct steering file loaded for platform
- [ ] Executive Summary includes feasibility score, 7Rs, Gartner TIME
- [ ] At least 6 different Mermaid diagram types included
- [ ] Current AND Target architecture diagrams present
- [ ] All proprietary dependencies analyzed
- [ ] Database technology detected and documented
- [ ] Exactly 3 pathways with full detail
- [ ] Cost-benefit analysis included
- [ ] Critical Findings Matrix has 10+ findings
- [ ] Risk of Inaction articulated for major findings
- [ ] Professional Advisory Notice included at end
- [ ] Report is comprehensive (500+ lines)
