# Obsidian Skill Manager

[![GitHub](https://img.shields.io/badge/GitHub-x1Rz47%2Fobsidian--skill--manager-blue)](https://github.com/x1Rz47/obsidian-skill-manager)

An AI agent skill for OpenCode, Claude Code, and Codex CLI that manages tool documentation in an Obsidian 知识库 — automatic classification, numbering, device tracking, template synchronization, and standardization across Mac and Windows.

## Install

```bash
npx skills add x1Rz47/obsidian-skill-manager@obsidian-skill-manager
```

Auto-detects all agents on your machine and symlinks the skill into each one's directory.

## Configure

Create `{SKILL_DIR}/SKILL.local.md` with your machine's hostname and vault path:

```markdown
## Device Configuration

| Hostname | Device | VAULT_BASE |
|----------|--------|------------|
| my-hostname | My Mac | /path/to/vault/04.AI相关-🤖 |
```

Find your hostname with `hostname -s` (macOS) or `hostname` (Windows). `SKILL.local.md` is gitignored and stays on your machine.

The skill only manages documents under `{VAULT_BASE}/01.辅助工具/` (the `{SCOPE}`). Anything elsewhere in the vault (e.g. `02.工具使用/`) is out of scope.

## Validation

- `scripts/validate_schema.py` — **authoritative** schema validator (Python 3, cross-platform). Strictly checks frontmatter, section order, skeletons, and forbidden patterns.
- `scripts/validate-format.sh` / `fix-format.sh` — legacy bash wrappers that call the Python validator after their own checks. Require bash (WSL or Git Bash on Windows).

## Workflows

The skill activates on natural-language triggers. See [`SKILL.md`](SKILL.md) for the full trigger table and detailed procedures.

| Workflow | Trigger (natural language) | What it does |
|----------|---------------------------|-------------|
| **Doc Management** | "记录 [工具]" / "doc [tool]" / "更新目录" / "重新分类" / "重新编号" / "重整" | Create, update, or restructure 知识库 docs from links/tool names/batch/full vault |
| **Tool Deploy** | "安装/下载/部署/install/setup/add/deploy" | Scan 知识库 for `必用: true` tools and install them on this machine |
| **Format Repair** | "修复/检查/同步/模板变了/fix/format/template changed/standardize" | Template sync, format repair (frontmatter/sections/markdown), content completion |

## Classification

Tools are categorized by **ability domain** (what capability does this tool give an AI Agent). The `类型` field marks the technical form, independent of directory location:

| Type | Meaning | Examples |
|------|---------|---------|
| **Agent** | Autonomous AI Agent or orchestration framework | Deep-Agents, Remote-OpenCode |
| **Skill** | Agent-executable SKILL.md instruction set | BrowserAct, Playwright, Agent-Reach |
| **Agent-Plugin** | Runtime extension injected into Agent | Supermemory, Morph, Vibeguard |
| **Guide** | Reference doc / methodology / workflow guide | Cheat-On-Content, Obsidian-Markdown |
| **MCP** | Model Context Protocol server | MarkItDown, CodeGraph, GBrain |
| **CLI** | Command-line standalone tool | yt-dlp, Repomix, DesktopCtl |
| **Library** | Programming library / SDK / Python package | PyAutoGUI, AISuite, GPT-SoVITS |
| **API** | Cloud service / API endpoint | (none yet) |
| **GUI** | Desktop GUI application | OmniVoice-Studio, AISuite |
| **Web** | Web application | Ian-Xiaohei-Illustrations, SkillOpt |
| **Plugin** | External software plugin (e.g. Obsidian plugin) | Claudian, Obsidian-Agent-Client |
| **Model** | AI model / dataset | (none yet) |
| **Collection** | Resource collection repo (doc-only management) | Superpowers, Anthropic, GStack |

## Device Tracking

| Tool Type | Detection |
|-----------|-----------|
| Agent skill | Directory exists or `npx skills list -g` / `claude skills list` |
| MCP server | Configured in agent config (`opencode.json`, `claude.json`, `codex config.toml`) |
| CLI tool | `which <tool>` (Mac) / `where.exe <tool>` (Win) |
| Homebrew | `brew list <pkg>` |
| npm global | `npm list -g <pkg>` |
| pip | `pip3 list \| grep <pkg>` |

## Files

| File | Purpose |
|------|---------|
| [`SKILL.md`](SKILL.md) | Full skill instructions (3 workflows, schema architecture, edge cases, conventions) |
| `SKILL.local.md` | Your device → vault mapping (gitignored, create after install) |
| [`TEMPLATE.md`](TEMPLATE.md) | Canonical 知识库 document template |
| `scripts/` | Format validators and fixers (`validate_schema.py` is authoritative; bash scripts are legacy) |

## License

MIT
