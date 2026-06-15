# Obsidian Skill Manager

An OpenCode skill that manages tool documentation in an Obsidian vault. Automatically records installed tools, tracks device status, syncs documentation, and keeps all files aligned with a standardized template.

[→ SKILL.md](obsidian-skill-manager/SKILL.md)

## Install

```bash
npx skills add x1Rz47/Obsidian-Skill-Manager@obsidian-skill-manager -g -y
```

## Quick Start

| Command | Description |
|---------|-------------|
| `安装 <tool>` | 自动记录到 Obsidian 知识库 |
| `部署到这台电脑` | 安装标记为 `必用: true` 的工具 |
| `执行` | 同步 vault 文档状态 |
| `模板变了` | 同步所有文档到最新模板格式 |

## Features

- **Recording** — Install any tool, auto-generate standardized docs with GitHub star sorting
- **Deployment** — Set up new devices from your `必用: true` list
- **Sync** — Re-index vault docs, fix frontmatter, update device tracking
- **Template Sync** — Normalize all vault files when template changes

## Structure

```
obsidian-skill-manager/
├── SKILL.md         ← Main skill definition
├── README.md        ← Detailed skill documentation
└── .gitignore
```

## License

MIT
