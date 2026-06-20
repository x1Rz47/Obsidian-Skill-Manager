# Obsidian Skill Manager

[![GitHub](https://img.shields.io/badge/GitHub-x1Rz47%2FObsidian--Skill--Manager-blue)](https://github.com/x1Rz47/Obsidian-Skill-Manager)

An OpenCode skill that manages tool documentation in an Obsidian vault — automatic classification, numbering, device tracking, template synchronization, and standardization.

## ✨ Features

- **8 workflows** covering install, document, sync, fix, and standardize
- **Template hash validation** — auto-detects when the vault template changes
- **Device tracking** — detects which tools are installed on each machine
- **Multi-device sync** — consistent documentation across Mac and Windows
- **Global re-sort** — renumbers files by GitHub stars across all categories
- **Automatic section filling** — web research populates empty template sections
- **Known Repo Mapping** — auto-fills GitHub links from a maintained lookup table

## 📦 Installation

```bash
npx skills add x1Rz47/Obsidian-Skill-Manager@obsidian-skill-manager
```

For development, symlink the local repo instead:

```bash
rm ~/.opencode/skills/obsidian-skill-manager
ln -s /path/to/Obsidian-Skill-Manager ~/.opencode/skills/obsidian-skill-manager
# repeat for ~/.agents/skills/obsidian-skill-manager if used
```

## ⚙️ Configuration

The skill detects the current device via `hostname -s` and maps it to vault paths:

| Hostname | Device Name | Vault Path |
|----------|-------------|------------|
| `x1Rz47-A1213` | Mac Mini | `/Users/x1rz47/Library/CloudStorage/.../04.AI相关-🤖` |
| `WPC-x1Rz47` | WPC | `D:\SynologyDrive\...\04.AI相关-🤖` |

Template file location: `{SKILL_DIR}/template.md`

Add new devices to the **Device Configuration** table in `SKILL.md`.

## 🔧 Workflows

| Workflow | What it does |
|----------|-------------|
| **Install** | Installs a tool, checks vault for existing docs first (skips doc if found), marks the device. Does not touch vault files |
| **Document** | Creates or updates a vault doc for a tool. Does not install anything |
| **Combined** | Install + auto-document if no existing doc found |
| **Deployment** | Scans vault for `必用: true` tools and installs them on the current device |
| **Fix** | Scans vault for known format issues (YAML errors, `@` prefix in aliases) and fixes them. No renumbering, no data refresh |
| **Sync** | Full vault scan — renumbers, validates frontmatter, updates device tracking, re-sorts by GitHub stars |
| **Template Sync** | When the template changes, propagates new field order, section structure, and defaults to every file. Also refreshes GitHub star counts and dates |
| **Standardize** | Full vault standardization — fix format, normalize frontmatter, reorder sections, fill empty sections via web research, refresh data, re-sort by stars |

## 📁 Vault Structure

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

## 🏷️ Classification Principle

Tools are classified by **execution context** — where does the tool actually run?

| Type | Runs In | Examples |
|------|---------|----------|
| **MCP** | Agent internal (protocol) | MarkItDown-MCP, CodeGraph |
| **Skill** | Agent internal (instruction set) | Playwright-skill, Agent-Reach |
| **Plugin** | Agent internal (runtime injection) | supermemory, morph |
| **Tool** | Agent **external** | yt-dlp, repomix, ffmpeg |

If a tool doesn't fit MCP / Skill / Plugin, it goes under `工具/`.

## 💻 Device Tracking

`使用设备` tracks whether a tool is **actually installed** on the current machine, not whether it could be used:

| Tool Type | Detection Method |
|-----------|-----------------|
| Agent skill | `npx skills list -g` or directory exists |
| MCP server | Configured in `opencode.jsonc` |
| CLI tool | `which <tool>` (Mac) / `where.exe <tool>` (Win) |
| brew package | `brew list <pkg>` (Mac only) |
| npm global | `npm list -g <pkg>` |
| pip package | `pip3 list \| grep <pkg>` |

Skills-Packs are always `N/A` (not individually installable).

## 🔗 See Also

- [`SKILL.md`](SKILL.md) — full workflow documentation, classification guide, naming conventions, edge cases, anti-patterns, and Known Repo Mapping table
- [`template.md`](template.md) — vault document template
