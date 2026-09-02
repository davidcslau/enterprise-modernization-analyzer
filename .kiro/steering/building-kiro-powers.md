---
inclusion: manual
---

# Building Kiro Powers

## What is a Kiro Power?

A Kiro power is a unified bundle that packages MCP tools, steering files, and hooks into a single installable unit. It gives your AI agent specialized knowledge without overwhelming context.

## Core Power Structure

A Kiro power consists of these predetermined files and components:

### 1. POWER.md (Required)

The main entry point file with two parts:

**Frontmatter (YAML format):**

```yaml
---
name: "power-name"
displayName: "Human Readable Name"
description: "What this power does"
keywords: ["trigger", "words", "for", "activation"]
---
```

**Body Content:**

- **Onboarding Section**: Step-by-step setup instructions
  - Step 1: Validate tools work (check prerequisites and dependencies)
  - Step 2: Add hooks (create hooks for triggered actions)
  - Step 3: Setup configuration (initialize required settings)

- **Steering File Map**: Instructions on when to load specific steering files

```markdown
# When to Load Steering Files

- Workflow A → steering-file-a.md
- Workflow B → steering-file-b.md
- Workflow C → steering-file-c.md
```

### 2. MCP Server Configuration (Required if using MCP tools)

JSON configuration file for MCP server connections:

```json
{
  "mcpServers": {
    "power-tools": {
      "command": "power-mcp-server",
      "args": ["--config", "config.json"]
    }
  }
}
```

### 3. Steering Files (Optional but recommended)

Workflow-specific markdown files loaded on-demand:

- `database-setup-workflow.md`
- `authentication-patterns.md`
- `deployment-best-practices.md`
- Additional domain-specific steering files as needed

### 4. Hooks (Optional)

JSON configuration for automated actions:

```json
{
  "enabled": true,
  "name": "Verify Best Practices",
  "when": {
    "type": "userTriggered"
  },
  "then": {
    "type": "askAgent",
    "prompt": "Check for security and performance concerns"
  }
}
```

## Complete Bundle Structure

```
my-power/
├── POWER.md                          # Main entry point (required)
├── mcp.json                   # MCP server configuration (if needed)
├── steering/                         # Additional steering files (optional)
│   ├── workflow-a.md
│   ├── workflow-b.md
│   └── workflow-c.md
└── hooks/                            # Hook configurations (optional)
    └── validation-hook.json
```

## Key Characteristics

### Three-Component Bundle

- **POWER.md** - Tells the agent what MCP tools are available and when to use them
- **MCP server configuration** - Tools and connection details for the MCP server
- **Steering/hooks** - Automated tasks that run on IDE events or via slash commands (optional)

### Dynamic Loading

- Powers activate based on keywords mentioned in conversation
- Load only relevant context when needed
- Automatically deactivate when no longer relevant

### File Organization Best Practices

- If your power is complex, separate it into multiple steering files
- Structure instructions as onboarding steps and steering instructions
- Keep workflows and best practices organized by domain

This structure allows Kiro to dynamically load specialized knowledge and tools on-demand, preventing context overflow while providing comprehensive framework expertise when needed.

## How to Create Your Power

1. **Visit the creation page**: Go to kiro.dev/docs/powers/create/
2. **Configure MCP connections**: Set up the tools your power will use
3. **Add steering guidance**: Create the POWER.md and workflow-specific steering files
4. **Define validation hooks**: Set up automated checks if needed
5. **Test in Kiro IDE**: Validate that dynamic loading works correctly
