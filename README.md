# Obsidian Skill Manager

[![GitHub](https://img.shields.io/badge/GitHub-x1Rz47%2FObsidian--Skill--Manager-blue)](https://github.com/x1Rz47/Obsidian-Skill-Manager)

OpenCode skill — 自动管理工具文档到 Obsidian 知识库，支持多设备追踪和模板同步。

[→ SKILL.md](SKILL.md)

## 安装

```bash
npx skills add x1Rz47/Obsidian-Skill-Manager -g -y
```

## 快速使用

| 命令 | 说明 |
|------|------|
| `安装 <tool>` | 安装工具并自动记录到 Obsidian |
| `部署到这台电脑` | 在新设备安装 `必用: true` 的工具 |
| `执行` / `sync` | 扫描并修复 vault 文档状态 |
| `模板变了` | 同步所有文档到最新模板格式 |

## 四个工作流

- **Recording** — 安装时自动归类、按 GitHub Star 排号、生成标准化文档
- **Deployment** — 跨设备部署标记为 `必用` 的工具
- **Sync** — 修复 frontmatter、编号、设备标记
- **Template Sync** — 模板变更时级联更新所有 vault 文件

## 目录结构

```
Obsidian-Skill-Manager/
├── SKILL.md      主技能定义
├── README.md     本文档
└── .gitignore
```

## License

MIT
