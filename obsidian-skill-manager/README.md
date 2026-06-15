# Obsidian Skill Manager

An OpenCode skill that manages tool documentation in an Obsidian vault. Automatically records installed tools, tracks device status, syncs documentation, and keeps all files aligned with a standardized template.

## Features

- **Recording** — When installing any tool, auto-detect category, assign number by GitHub stars, and generate standardized docs in the vault
- **Deployment** — Set up new devices by scanning `必用: true` tools and installing them
- **Sync** — Keep vault docs in sync with actual install state across multiple devices
- **Template Sync** — Normalize all vault files to match the latest template format

## Directory Structure

| Directory | Content | Sorting |
|-----------|---------|---------|
| `开发辅助/` | Development & code review skills | By GitHub stars |
| `搜索代理/` | Search & info retrieval skills | By GitHub stars |
| `浏览器自动化/` | Browser automation skills | By GitHub stars |
| `媒体创作/` | Video & animation creation skills | By GitHub stars |
| `知识管理/` | Knowledge management skills | By GitHub stars |
| `启动验证/` | Startup validation skills | By GitHub stars |
| `效率工具/` | Utility & orchestration skills | By GitHub stars |
| `工作流指南/` | Workflow/process docs | Per-subdir numbering |
| `平台技能/Superpowers/核心技能/` | Core superpowers skills (14) | Fixed 01-14 |
| `平台技能/Codex/` | Codex-native skills | Manual |
| `平台技能/Obsidian/` | Obsidian-specific skills | By GitHub stars |
| `MCP/` | MCP server tools | Manual |
| `插件/` | Plugins | Manual |

## Device Tracking

Tracks which tools are installed on each device via `使用设备` frontmatter field. Auto-detects install status using `which`, `brew list`, `npm list -g`, `pip list`, `npx skills list -g`, and MCP config.

## Requirements

- OpenCode (or compatible agent)
- Obsidian vault with SynologyDrive or local storage
- Node.js / npm

## Installation

```bash
npx skills add x1Rz47/Obsidian-Skill-Manager@obsidian-skill-manager -g -y
```

## License

MIT
