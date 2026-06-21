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

## Workflows

The skill activates on natural-language triggers. See [`SKILL.md`](SKILL.md) for the full trigger table and detailed procedures.

| Workflow | What it does |
|----------|-------------|
| **安装** | Install a tool, skip doc if it already exists, mark the device |
| **记录** | Create or update a 知识库 doc without installing anything |
| **综合** | Install + auto-document if no existing doc |
| **部署** | Scan 知识库 for `必用: true` tools and install them on this machine |
| **修复** | Auto-fix YAML errors, alias formats, and other common issues |
| **同步** | Full scan: renumber, re-sort by stars, validate frontmatter, update device tracking |
| **模板同步** | Propagate template changes (field order, sections, defaults) to every doc |
| **标准化** | Full pipeline: fix → sync → refresh → web research → re-sort |

## Classification

Tools are categorized by execution context:

| Type | Where it runs | Examples |
|------|-------------|---------|
| **MCP** | Agent internal (protocol) | MarkItDown-MCP, CodeGraph |
| **Skill** | Agent internal (instruction set) | Playwright-skill, Agent-Reach |
| **Plugin** | Agent internal (runtime injection) | supermemory, morph |
| **Tool** | Agent external | yt-dlp, repomix, ffmpeg |

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
| [`SKILL.md`](SKILL.md) | Full skill instructions (8 workflows, edge cases, conventions) |
| `SKILL.local.md` | Your device → vault mapping (gitignored, create after install) |
| [`TEMPLATE.md`](TEMPLATE.md) | Canonical 知识库 document template |
| `scripts/` | Format validators and fixers |

## License

MIT
