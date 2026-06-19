# Obsidian Skill Manager

[![GitHub](https://img.shields.io/badge/GitHub-x1Rz47%2FObsidian--Skill--Manager-blue)](https://github.com/x1Rz47/Obsidian-Skill-Manager)

An OpenCode skill that manages tool documentation in an Obsidian vault — automatic classification, numbering, device tracking, and template synchronization.

## Installation

```bash
npx skills add x1Rz47/Obsidian-Skill-Manager@obsidian-skill-manager
```

## Workflows

| Workflow | What it does |
|----------|-------------|
| **Install** | Installs a tool, checks vault for existing docs first (skips doc if found), marks the device. Does not touch vault files |
| **Document** | Creates or updates a vault doc for a tool. Does not install anything |
| **Combined** | Install + auto-document if no existing doc found |
| **Deployment** | Scans the vault for `必用: true` tools, infers install commands, and sets them up on a new machine |
| **Sync** | Scans all vault files, fixes numbering gaps, re-sorts by stars, validates frontmatter, and updates device tracking |
| **Template Sync** | When `00-工具功能介绍模板.md` changes, propagates the new field order, section structure, and defaults to every file |

## Vault Structure

```
辅助工具/
├── Skills/           # Agent SKILL.md instruction sets, grouped by domain
│   ├── 浏览器自动化/
│   ├── 媒体创作/
│   ├── 搜索代理/
│   ├── 效率工具/
│   ├── 启动验证/
│   └── 知识管理/
├── Skills-Packs/     # Multi-skill repositories (Superpowers, Anthropic, etc.)
├── 工具/             # Standalone CLIs, Obsidian plugins, libraries
├── 插件/             # Agent runtime-injection plugins (supermemory, morph, etc.)
└── MCP/              # MCP protocol tools (MarkItDown, CodeGraph, GBrain)
```

## Classification Principle

Tools are classified by **execution context** — where does the tool actually run?

- Agent **external** (standalone CLI, Obsidian plugin, VS Code extension) → `工具/`
- Agent **internal** (SKILL.md instruction set) → `Skills/`
- Agent **internal** (runtime injection) → `插件/`
- Agent **internal** (MCP protocol) → `MCP/`

See `SKILL.md` for the full classification guide, workflow steps, naming conventions, and anti-patterns.
