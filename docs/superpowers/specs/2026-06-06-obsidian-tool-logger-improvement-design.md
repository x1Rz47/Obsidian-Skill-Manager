# Obsidian Tool Logger v2 — 改进设计

## 目标

改进 `obsidian-tool-logger` skill，覆盖两个核心工作流：

**工作流 A —— 安装/记录**
1. 按 GitHub 星标全局排序并自动重编号
2. 自动检测工具类型并分配到对应目录
3. GitHub fetch 失败时优雅降级
4. 检查已有文档，支持更新而非重复创建
5. 增加 Red Flags / Rationalization Table / Edge Cases 防止走捷径

**工作流 B —— 部署到新设备**
6. 读取 `Skills/General/` 常用工具列表，在新设备上自动安装
7. 同时部署对应的 opencode skill 配置
8. 输出部署报告

## 改动点

### 1. Description

```
Before: Use when the user says "install", "download", "add", or "设置" a tool, skill, plugin, MCP server, npm package, or any other software component. Triggers when the user wants to record tool information into their Obsidian vault.

After: Use when the user asks to install, download, add, or set up any software component
```

去掉工作流描述，避免 CSO 陷阱。

### 2. 编号逻辑变更

- 新文件不再简单地 `{N+1}` 递增
- 改为按 `Github星标` 降序全局排位
- 星标相等时按工具名字母序
- 无 GitHub 的工具星标 = `N/A`，始终放末尾
- 每次新增时读取目录下所有文件的 frontmatter，全局重新排序 + 重编号
- 重编号涉及文件重命名（`{NN}-{Name}.md`）

### 3. 自动类别检测

| 安装来源 | 目标目录 |
|---------|---------|
| `npx skills add` / `npm install -g` | `Skills/General/` |
| vscode / obsidian / browser extensions | `插件/` |
| MCP server | `MCP/` |
| config / dotfiles | `Config/` |
| brew / pip / direct download | `其他/` |

### 4. 更新 vs 新建

- 读取目标目录所有文件的 frontmatter
- 检查 `工具名` 和 `aliases` 是否匹配
- 匹配 → 更新 `更新日期`，追加 `更新功能` 记录，合并新信息，**不改变编号**
- 不匹配 → 执行全局排序 + 重编号流程，新建文件

### 5. GitHub Fetch 容错

- fetch 成功 → 写入实际星标数
- fetch 失败（网络/无 GitHub）→ 写入 `N/A`，不阻塞
- 解析格式：`12K` → 12000，`1.5K` → 1500，`N/A` → 0

### 6. 新增 Red Flags / Rationalization Table / Edge Cases

详见 `SKILL.md` 中的对应章节。

### 7. 命名规范

在 SKILL.md 中新增 Naming Conventions 章节，规定：

**格式：** `{NN}-{Pascal-Kebab-Name}.md`
- 全英文，Pascal-kebab-case
- 从 frontmatter `工具名` 自动转换
- 每目录独立编号

### 8. 文件迁移（一次性执行）

将 `Skills/` 根目录 6 个 .md 文件移入 `Skills/General/`:
- `find-skills.md` → 替换已有的 `01-Find-Skills.md`（同一工具，数据更新）
- `manim-video.md`, `obsidian-tool-logger.md`, `pdf.md`, `playwright.md`, `video-use.md` → 移入 General 并参与星标排序

合并后共 16 个文件，按 GitHub 星标全局重排。

### 9. 新增——部署到新设备

**触发词**：`部署到这台电脑` / `安装常用` / `同步技能` / `deploy`

**流程**：
1. 扫描 `Skills/General/` 下所有 .md 文件
2. 筛选 `常用: true` 的文档
3. 对每个工具，AI 自动从文档推断安装命令并执行
4. 如果 `~/.config/opencode/skills/` 下存在对应的 opencode skill，一并部署
5. 输出部署报告（成功/失败/已存在）

**边缘情况**：
- 无 `常用: true` → 提示用户
- 工具已安装 → 跳过不重装
- 安装失败 → 记录错误，继续下一个
- 安装命令不明确 → 询问用户确认

## 目录结构

```
~/Desktop/AI/skills/obsidian-tool-logger/
  SKILL.md                    # 主要 skill 文件（更新）
~/.config/opencode/skills/obsidian-tool-logger/
  SKILL.md                    # 全局生效副本（同步）
```

## 不涉及

- opencode.jsonc 配置变更（skill 自动发现无需注册）
- Obsidian 模板文件修改
- 其他 skill 文件的修改
