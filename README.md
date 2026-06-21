# Obsidian Skill Manager

[![GitHub](https://img.shields.io/badge/GitHub-x1Rz47%2Fobsidian--skill--manager-blue)](https://github.com/x1Rz47/obsidian-skill-manager)

An AI agent skill (OpenCode / Claude Code / Codex CLI) that manages tool documentation in an Obsidian 知识库 — automatic classification, numbering, device tracking, template synchronization, and standardization.

## Quick Reference

| Command | Description |
|---------|-------------|
| `安装 <tool>` | Record tool into vault |
| `部署到这台电脑` | Install tools marked `必用: true` |
| `修复文档/检查格式` | Fix common format issues |
| `同步` | Full vault re-index, re-sort, device tracking |
| `模板变了` | Propagate template changes to all files |
| `标准化所有文档` | Run everything: fix, sync, refresh, research |

## Structure

```
My-Skills/Obsidian-Skill-Manager/
├── SKILL.md       ← Main skill (8 workflows, template sync)
├── TEMPLATE.md    ← Canonical doc template
├── scripts/       ← Format validators & fixers
└── README.md      ← Detailed docs
```

## ✨ Features

- **8 个工作流** covering install, document, sync, fix, and standardize
- **Template hash validation** — auto-detects when the 知识库 template changes
- **Device tracking** — detects which tools are installed on each machine
- **Multi-device sync** — consistent documentation across Mac and Windows
- **Global re-sort** — renumbers files by GitHub stars across all categories
- **Automatic section filling** — web research populates empty template sections

## 📦 Installation

```bash
npx skills add x1Rz47/obsidian-skill-manager@obsidian-skill-manager
```

[Vercel's `npx skills add`](https://github.com/vercel-labs/skills) auto-detects OpenCode, Claude Code, Codex CLI, and 40+ other agents on your machine, then symlinks the skill into each platform's directory. One command, all platforms.

### Development

Symlink the local repo manually for active development:

```bash
# Remove installed copy first (if any)
rm ~/.agents/skills/obsidian-skill-manager

# Symlink repo to universal agents path
ln -s /path/to/obsidian-skill-manager ~/.agents/skills/obsidian-skill-manager

# Optionally symlink to specific platforms
ln -s /path/to/obsidian-skill-manager ~/.config/opencode/skills/obsidian-skill-manager
ln -s /path/to/obsidian-skill-manager ~/.claude/skills/obsidian-skill-manager
ln -s /path/to/obsidian-skill-manager ~/.codex/skills/obsidian-skill-manager
```

## ⚙️ Configuration

The skill detects the current device via `hostname -s` and maps it to 知识库 paths:

| Hostname | Device Name | 知识库 Path |
|----------|-------------|------------|
| `x1Rz47-A1213` | Mac Mini | `/Users/x1rz47/Library/CloudStorage/.../04.AI相关-🤖` |
| `WPC-x1Rz47` | WPC | `D:\SynologyDrive\...\04.AI相关-🤖` |

Template file location: `{SKILL_DIR}/TEMPLATE.md`

Add new devices to the **Device Configuration** table in `SKILL.md`.

## 🔧 工作流

| 工作流 | What it does |
|----------|-------------|
| **安装** | Installs a tool, checks 知识库 for existing docs first (skips doc if found), marks the device. Does not touch 知识库 files |
| **记录** | Creates or updates a 知识库 doc for a tool. Does not install anything |
| **综合** | Install + auto-document if no existing doc found |
| **部署** | Scans 知识库 for `必用: true` tools and installs them on the current device |
| **修复** | Scans 知识库 for known format issues (YAML errors, `@` prefix in aliases) and fixes them. No renumbering, no data refresh |
| **同步** | Full 知识库 scan — renumbers, validates frontmatter, updates device tracking, re-sorts by GitHub stars |
| **模板同步** | When the template changes, propagates new field order, section structure, and defaults to every file. Also refreshes GitHub star counts and dates |
| **标准化** | Full 知识库 standardization — fix format, normalize frontmatter, reorder sections, fill empty sections via web research, refresh data, re-sort by stars |

## 📁 知识库目录结构

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
| Agent skill | Skill list visible or directory exists (`npx skills list -g`, `claude skills list`, or auto-detected) |
| MCP server | Configured in agent config (`opencode.json`, `claude.json`, `codex config.toml`) |
| CLI tool | `which <tool>` (Mac) / `where.exe <tool>` (Win) |
| brew package | `brew list <pkg>` (Mac only) |
| npm global | `npm list -g <pkg>` |
| pip package | `pip3 list \| grep <pkg>` |

Skills-Packs are always `N/A` (not individually installable).

## 🔗 See Also

- [`SKILL.md`](SKILL.md) — 完整工作流文档, classification guide, naming conventions, edge cases, anti-patterns
- [`TEMPLATE.md`](TEMPLATE.md) — 知识库 document template

## License

MIT
