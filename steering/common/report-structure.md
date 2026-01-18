---
inclusion: fileMatch
fileMatchPattern: "POWER.md"
---

# Modernization Report Structure

This defines the standard report structure for ALL modernization analyses.

## Report Sections

### 1. Executive Summary

MUST include:

- **Strategic Verdict Table**:
  | Dimension | Assessment |
  |-----------|------------|
  | Overall Feasibility | ✅/⚠️/❌ RATING (X/10) |
  | 7 Rs Classification | Classification |
  | Gartner TIME Model | Classification |
  | Recommended Target | Target platform |
  | Risk Level | LEVEL - Description |

- **Modernization Areas Summary Table** (high-level by area):
  | Area | Status | Complexity | Key Action |
  |------|--------|------------|------------|
  | Platform & Framework | ⚠️/✅/❌ | Low/Medium/High | Brief action |

- **Positive Indicators** (bullet list of what's already good)
- **Critical Blockers** (bullet list of what must change)
- **Risk of Inaction Table**:
  | Risk Category | Impact | Probability | Business Consequence |
  |---------------|--------|-------------|---------------------|

### 2. Visual Architecture State

MUST include Mermaid.js diagrams:

- **Current Architecture Diagram** - Show all layers with technologies
- **Target Architecture Diagram** - Show modernized stack
- **Dependency Graph** - Project and package dependencies

Color coding:
- 🔴 Red: Critical blockers
- 🟠 Orange: Concerns requiring attention
- 🟢 Green: Good/modernized components

### 3. Critical Findings Matrix

| # | Issue | Evaluation Area | Impact | Impact If Not Modernized | Priority |
|---|-------|-----------------|--------|--------------------------|----------|
| 1 | Issue description | Area | 🔴/🟠/🟡 LEVEL | Detailed consequence | P0/P1/P2/P3 |

Priority levels:
- P0: Critical blocker - must fix before migration
- P1: High priority - address in first phase
- P2: Medium priority - address in subsequent phases
- P3: Low priority - nice to have

### 4. Proprietary Dependency Analysis

Include license verification note:
> 📋 **License Verification**: Package licenses verified via official package registry APIs.

**Summary Table**:
| Library | Version | License (SPDX) | Verified | Migration Status | Impact | Mitigation |
|---------|---------|----------------|----------|------------------|--------|------------|

For EACH significant proprietary library, provide:
- Current usage description
- Migration compatibility assessment
- Mitigation options with effort levels
- Code migration examples (before/after)

### 5. Database Analysis & Migration Opportunity

**Detection Summary**:
| Aspect | Finding |
|--------|---------|
| Database Technology | SQL Server / Oracle / DB2 / MySQL / PostgreSQL |
| Data Access Pattern | ORM / Raw SQL / Stored Procedures |
| Connection Locations | List of config files |
| Database-Specific Features | List of vendor-specific features |

**Migration Recommendations**:
- Target database options with pros/cons
- Migration complexity assessment
- Code changes required
- Cost savings potential

### 6. Recommended Pathways

Generate exactly 3 distinct pathways ranked by Approachability (1-10):

**Pathway Comparison Matrix** (Mermaid quadrantChart):
- X-axis: Low Effort → High Effort
- Y-axis: Low Value → High Value

For each pathway:

**Pathway N: [Name] (Approachability: X/10)**
- 7 Rs Classification
- Gartner TIME Classification
- Strategy Overview
- Migration Roadmap (Mermaid flowchart)
- Effort Breakdown Table:
  | Phase | Complexity | Relative Sequence | Key Deliverables |
  |-------|------------|-------------------|------------------|
- Risk Assessment
- When to choose this path

### 7. Next Steps

**Quick Wins (Low Complexity)**
- Mermaid gantt diagram showing immediate actions
- Action items table:
  | Action | Owner | Complexity | Impact |
  |--------|-------|------------|--------|

**Strategic Initiatives (Medium-High Complexity)**
- Mermaid flowchart showing dependencies
- Initiative descriptions with sequencing

**Recommended Tool Support**:
| Tool | Purpose | Phase |
|------|---------|-------|

### 8. Cost-Benefit Analysis

**Cost Comparison Table**:
| Configuration | Compute | Database | Licensing | Overall | Savings |
|--------------|---------|----------|-----------|---------|---------|
| Current | Level | Level | Level | Level | Baseline |
| Option 1 | Level | Level | Level | Level | X% |
| Option 2 | Level | Level | Level | Level | X% |

Use qualitative levels: Low/Medium/High/Very High

**ROI Summary**:
- Investment level
- Returns potential
- Value realization timeline

### 9. Professional Advisory Notice

MUST include this EXACT notice at the end:

> 📋 **Professional Advisory Notice**: This report provides a high-level technical analysis based on automated codebase scanning and should be interpreted in consultation with AWS Modernization Specialists or authorized AWS Modernization Partners. The findings and recommendations herein are intended to inform strategic planning discussions and should not be acted upon directly without professional guidance. Implementation effectiveness is influenced by numerous factors that cannot be extracted from the codebase alone, including organizational readiness, team dynamics, business constraints, regulatory requirements, and market conditions. We recommend engaging with qualified modernization experts to develop a comprehensive implementation strategy tailored to your specific organizational context.

## Visualization Standards

### Mermaid Diagram Types to Use

1. **Architecture Diagrams**: `graph TB` or `graph LR`
2. **Dependency Graphs**: `graph TD`
3. **Flowcharts**: `flowchart LR` or `flowchart TB`
4. **Quadrant Charts**: `quadrantChart`
5. **Gantt Charts**: `gantt`
6. **XY Charts**: `xychart-beta`

### Diagram Best Practices

- Use clear, descriptive labels
- Include legends for color coding
- Show clear boundaries between components
- Annotate with technology decisions
- Keep diagrams readable (not too complex)

## Quality Checklist

Before completing the report, verify:

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
