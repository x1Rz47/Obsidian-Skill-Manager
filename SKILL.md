---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when the 知识库 agent skill documentation needs organizing, renaming, standardizing, fixing, or format-checking. Also use when the 知识库 documentation template changes and all files need syncing to match. Also use when the user says fix docs, fix format, 修复文档, 修复格式, or 检查格式. Compatible with any SKILL.md-based AI coding assistant.
---
<!-- WARNING: All section lists must be read from TEMPLATE.md, never hardcoded. -->

# Obsidian Skill Manager

## Triggering

This skill activates in six modes:

| Mode | Trigger phrases |
|------|----------------|
| **Install** | "安装/下载 [工具]"、"install/setup/add [tool]" |
| **Document** | "记录 [工具]"、"给 [工具] 写个文档"、"doc [tool]" |
| **Deployment** | "部署/安装必用/安装常用/部署技能"、"deploy/setup this machine" |
| **Fix** | "修复文档/修复格式/检查格式/清理"、"fix docs" |
| **Sync** | "同步/重新编号/重新索引"、"sync/reindex" |
| **Template Sync** | "模板变了/更新模板/同步模板"、"template changed" |

## 知识库配置

`{TEMPLATE}` = `{SKILL_DIR}/TEMPLATE.md`.

### Device → Vault Mapping

Variables are resolved at runtime:

| Variable | Source |
|----------|--------|
| `{HOSTNAME}` | `hostname -s` (macOS) / `hostname` (Windows) |
| `{SKILL_DIR}` | Auto-detected from skill install location |
| `{VAULT_BASE}` | Looked up from `{SKILL_DIR}/SKILL.local.md` by hostname |
| `{TEMPLATE}` | `{SKILL_DIR}/TEMPLATE.md` |

Resolution order:
1. If `{SKILL_DIR}/SKILL.local.md` exists, read its **Device Configuration** table
2. Match `{HOSTNAME}` against the table → determines `{VAULT_BASE}`
3. If no match or no local config → ask user for their hostname and vault path


## 规则

### 分类规则

所有层级统一按**能力域**分类。核心问题：**"AI Agent 通过这个工具获得了什么能力？"**

### 类型规则

`类型` 字段标注工具的技术形态，与目录位置无关。

**格式：** YAML 列表，一个工具可标注多个类型。

```yaml
类型:
  - CLI
  - MCP
```

| 取值 | 含义 | 示例 |
|------|------|------|
| `Agent` | 自主 AI Agent 或 Agent 编排框架 | Deep-Agents, Remote-OpenCode |
| `Skill` | Agent 可执行的 SKILL.md 指令集 | BrowserAct, Playwright, Agent-Reach |
| `Agent-Plugin` | 注入 Agent 运行时的扩展 | Supermemory, Morph, Vibeguard |
| `Guide` | 参考文档 / 方法论 / 工作流指南 | Cheat-On-Content, Obsidian-Markdown |
| `MCP` | Model Context Protocol 服务器 | MarkItDown, CodeGraph, GBrain |
| `CLI` | 命令行独立工具 | yt-dlp, Repomix, DesktopCtl |
| `Library` | 编程库 / SDK / Python 包 | PyAutoGUI, AISuite, GPT-SoVITS |
| `API` | 云服务 / API 接口 | （暂无） |
| `GUI` | 桌面图形应用 | OmniVoice-Studio, AISuite |
| `Web` | Web 应用 | Ian-Xiaohei-Illustrations, SkillOpt |
| `Plugin` | 外部软件插件（如 Obsidian 插件） | Claudian, Obsidian-Agent-Client |
| `Model` | AI 模型 / 数据集 | （暂无） |
| `Collection` | 资源集合仓库（仅管理文档） | Superpowers, Anthropic, GStack |

**规则：**
- 取值必须来自上方表格，不可自创
- 至少标注 1 个，建议不超过 3 个
- 多个类型按优先级排列：Agent → Skill → MCP → CLI → Library → API → Agent-Plugin → Plugin → Guide → GUI → Web → Model → Collection
- `类型` 独立于目录位置，同目录文件可以有不同 `类型`

### 目录层级规则

**格式：** `{VAULT_BASE}/辅助工具/{L1}/{L2}/{L3}/{L4}/{NN}-{名称}.md`

| 层级 | 建目录条件 | 说明 |
|------|-----------|------|
| **L1** | 不因文件数量合并/拆分 | 1 个文件也独立成目录 |
| **L2-L4** | 子能力域内文件 **>2** 个时创建子目录 | 递归适用；13 种类型混装视为同类 |

**规则：**
- L1 名称：`{NN}-{中文能力域名}`（`NN` 为两位数字 `01`-`99`），按拼音排序连续分配，用于固定显示顺序
- L2/L3/L4 名称：`{NN}-{中文子能力域名}`，NN 为两位数字，所属父目录内独立编号
- L1 的 `NN-` 数字前缀用于目录排序，文件名的 `NN-` 是各目录内独立编号，两者互不冲突
- 不限技术类型，13 种类型混装在同一个目录均视为同类

**新建前检查：** 当目录中有 >2 个文件属于同一子能力域时，创建子目录：
1. 确保每个文件的 `aliases` 中包含中文子能力域名（不含 NN 前缀），缺失则追加
2. 从文件所属子能力域提取中文域名（可能有多个，如 `视频制作`、`语音合成`）
3. 每个子能力域分别创建 `{NN}-{中文子能力域名}` 子目录，NN 按拼音首字母排序连续分配
4. 旧文档：移入对应子目录后按 GitHub stars 降序重新分配编号
5. 新文档：按 `{NN}-{英文名}` 格式命名，NN 接续当前目录最大编号

**递归：** 每次操作后，扫描所有已有目录（L2→L4），检查是否有剩余 >2 的聚类需要拆分。

### 命名规则

**格式：** `{NN}-{英文名}.md`
- `NN`：两位数编号（`01`、`02`...`99`）
- `英文名`：每个单词首字母大写，连词符连接，仅英文
- 示例：`12-Playwright.md`、`04-Data-Visualization.md`

**规则：**
- 只允许字母、数字、连词符和官方名中文
- 每个单词首字母大写，连词符连接（如 `Data-Visualization`）
- 官方名例外：保留工具官方名称原样（如 `PyAutoGUI`、`BrowserAct`、`ian-xiaohei-illustrations`），不强行拆连词符或翻译
- 无空格、无下划线、无其他特殊字符
- 不追加类型后缀：文件名不出现 `-mcp`、`-plugin`、`-skill`——目录路径已表达类型
- 去厂商前缀：`opencode-X` → `X`、`vscode-X` → `X`，除非前缀是工具官方标识的一部分
- 模板文件（`00-*`）不参与编号
- 每个目录独立编号（含 L3 子目录）


### 别名规则

每个文件的 `aliases` 按以下规则填写，最多不超过 **5** 个条目：

| # | 条目 | 规则 | 示例 |
|---|------|------|------|
| 1 | 英文名 | 有则写，无则跳过。Pascal Case 无连词符，只写一个 | `BrowserAct` |
| 2 | 中文名 | 有则写，无则跳过。所属目录的中文能力域名（不含 NN 编号），位置不限 | `视频制作` |
| 3+ | 核心技术关键词 | 至少 1 个，从文档简介/核心功能提取，可有多个 | `浏览器控制`、`Web自动化` |

### 前置元数据规则

被同步和模板同步工作流共享。在其他工作流逻辑前对每个 `.md` 文件执行以下检查：

| 检查项 | 修复方式 |
|-------|---------|
| `字段顺序` 错误 | 按 `{TEMPLATE}` 的 frontmatter 键顺序重新排列 |
| `类型:` 缺失 | 添加为 YAML 列表，取值见[类型规则](#类型规则) |
| `类型:` 非列表 | 转为 YAML 列表：`类型: X` → `类型:\n  - X`；多类型追加全部取值 |
| `使用平台:` 无效 | 通用工具填 `ALL`，Agent 专用工具从 `OpenCode / Codex / Claude Code / Gemini` 中用 ` / ` 分隔选择。禁止 `NO`、`N/A` 等模糊值 |
| `使用设备:` 格式错误 | 修正为 YAML 列表（`  - Device`）或 `N/A` |
| `使用设备:` 缺失 | 检测当前设备安装状态：已安装追加设备名，未安装设 `N/A` |
| 布尔值未小写 | 修复：`True` → `true`，`False` → `false`，`Yes` → `yes` |

### 文档规则

文档 body 严格按 `{TEMPLATE}` 的 `##` 节结构和格式生成。各节的写法和示例见模板本身，不再重复。

#### `📝 更新功能` 书写规范

- 文档仅有 1 条更新记录时，描述统一写 `首次创建`
- 文档有 2+ 条记录时，第一条写 `首次创建`，第二条起内容不限
- 模板变更（增删字段、重排结构、格式化）**不记入** `更新功能`，仅联网查到的新内容更新才记录
- 更新记录描述尽量简短，一句话概括做了什么即可，不必展开细节

#### 更新操作

当任一工作流更新已有文档时，始终执行以下操作：

| 字段 | 操作 |
|------|------|
| `GitHub Star` | 重新查网页，更新最新 star 数；查不到则保留原值 |
| `更新日期` | 设为当天 `YYYY-MM-DD` |
| `更新功能` | 仅联网查到的新内容更新才追记；模板变更不记录 |
| `已有内容` | 合并新信息到对应章节，新旧重复或矛盾时以新资料为准覆盖 |
| `创建日期` | **不变** |
| `文件编号` | 按 GitHub stars 排序重新分配 |
| `使用设备` | 检测当前设备安装状态：已安装追加设备名，未安装设 `N/A` |

### 安装检测规则

| 安装类型 | 判定命令 | 示例 |
|---------|---------|------|
| CLI 工具 | `which <tool>`（Mac）/ `where.exe <tool>`（Win） | `ffmpeg` |
| brew 包 | `brew list <pkg>`（仅 Mac） | `gh` |
| npm 全局包 | `npm list -g <pkg>` | `bun` |
| pip 包 | `pip3 list \| grep <pkg>`（Mac）/ `pip list \| findstr <pkg>`（Win） | `openai-whisper` |
| 工作流/Collection | 不可安装，永远写 `N/A` | GStack, Superpowers |


## 工作流

### 通用步骤

#### 查知识库

在目标目录中搜索已有文档：
1. 读取目标目录下所有 `.md` 文件
2. 按文件名（去掉 `NN-` 前缀）或第一个 `aliases` 条目匹配
3. **找到** → 继续后续步骤
4. **未找到** → 跳至[完整搜资](#完整搜资)

#### 查最新star

获取当前 GitHub star 数：
- 工具有 GitHub 链接 → 抓取页面解析 star 数
- 抓取失败或没有 GitHub 仓库 → 保留原有 `GitHub Star`

#### 完整搜资

收集以下信息：
- 官方 README / 文档中的简介
- GitHub 链接和 star 数（用搜索引擎或 GitHub API）
- 安装命令（如 I1 已确定则跳过）
- 核心功能、依赖项、`使用平台`
- 注意事项或已知限制

GitHub 抓取失败时设 `GitHub Star: N/A`。

#### 安装

执行安装命令。等待完成。验证成功或失败。

安装后从知识库配置表记录当前设备名。设备检测参照[前置元数据规则](#前置元数据规则)。

告知用户结果："安装成功"或"安装失败：[原因]"。

#### 生成文档

写入前检查[目录层级规则](#目录层级规则)：
- 目标目录存在 >2 个同子能力域文件 → 创建子分类文件夹、移入、重编号
- 否则直接使用当前目录

用完整搜资的数据创建文档：
- 读取 `{TEMPLATE}` 获取字段顺序、章节结构和书写规则
- 填充 `GitHub 链接`、`GitHub Star`、简介、核心功能、`使用平台`
- `创建日期` 和 `更新日期` 设为当天
- `使用设备` 设为当前设备
- 取目标目录中下一个可用编号（最大 `NN` + 1，空目录从 `01` 开始）
- 写入 `{VAULT_BASE}/{category}/{NN}-{英文名}.md`
- 告知用户："已生成文档：{filename}"

### 安装工作流

#### I1: 识别工具

确定以下信息：
- **名称**：工具叫什么？
- **来源**：GitHub / npm / brew / pip / direct download
- **分类**：根据来源映射到知识库目录（参照[同步工作流 S2](#s2-扫描全部知识库目录)）

→ 跳至[查知识库](#查知识库)

#### ═══ 已有文档 ═══

#### 查最新star

参照[通用步骤 - 查最新star](#查最新star)。

#### 安装

参照[通用步骤 - 安装](#安装)。

#### I5: 更新文档

应用[文档规则](#文档规则)：
- 安装成功 → 全部规则（star/日期/更新功能/内容/设备）
- 安装失败 → 只更新 `更新日期` + `更新功能`（追加 "YYYY-MM-DD: 安装失败：[原因]"），其余不变

---

#### ═══ 无文档 ═══

#### 完整搜资

参照[通用步骤 - 完整搜资](#完整搜资)。

#### 安装

参照[通用步骤 - 安装](#安装)。

#### I7: 生成文档

参照[通用步骤 - 生成文档](#生成文档)。

---

### 记录工作流

#### W1: 查知识库

识别工具（名称、类型、分类），参照[通用步骤 - 查知识库](#查知识库)：
- 找到 → 跳至 W2: 更新文档
- 未找到 → 跳至 W3: 完整搜资

#### W2: 更新文档

应用[文档规则](#文档规则)：
- 自动搜最新 GitHub star、更新日期、追记更新功能、合并新信息
- 如果用户提供了新信息，优先用用户提供的内容合并

---

#### W3: 完整搜资

参照[通用步骤 - 完整搜资](#完整搜资)。

#### W4: 生成文档

参照[通用步骤 - 生成文档](#生成文档)。

---

### 部署工作流

扫描知识库中标记 `必用: true` 的工具，在当前设备上安装。

#### D1: 扫描必用工具

1. 读取 `{VAULT_BASE}/辅助工具/` 下所有 `.md` 文件（递归所有子目录）
2. 解析每个文件的 frontmatter，筛选 `必用: true`
3. 无结果则报告"没有标记必用的工具"并停止

#### D2: 逐个安装

对每个 `必用: true` 的文件：

1. 读取文档正文，重点关注**用法**和**核心功能**章节
2. 从内容推断安装命令
3. 判断安装类型：
   - **系统工具**（brew/pip/npm）→ 直接执行安装命令
   - **Agent 技能** → 链接/复制到当前平台的 skill 目录（OpenCode: `~/.config/opencode/skills/`，Claude Code: `~/.claude/skills/`，Codex: `~/.codex/skills/` 或 `$REPO_ROOT/.agents/skills/`）
4. 检查是否已安装 — 已安装则跳过
5. 执行安装命令。验证成功。
6. 记录成功或失败

#### D3: 报告结果

展示每个工具的安装状态汇总表。

### 同步工作流

此工作流独立运行。在手动增删或重命名知识库文件后，用于恢复所有目录的编号一致性。

#### S1: 确定当前设备

按[设备到知识库映射](#device--vault-mapping)的解析顺序确定 `{HOSTNAME}` 和 `{VAULT_BASE}`。

#### S2: 扫描全部知识库目录

递归扫描 `{VAULT_BASE}/辅助工具/` 下所有含 `.md` 文件的目录。对每个文件解析 frontmatter 并构建清单：工具名、`GitHub Star`、`使用设备`、`必用`、安装命令。

扫描前递归应用[目录层级规则](#目录层级规则)，确保没有 >2 个同子能力域未拆分。

#### S3: 检测并修复文件问题

对每个文件应用[前置元数据规则](#前置元数据规则)，外加同步专属检查：

| 检查项 | 修复方式 |
|-------|---------|
| 缺少 `必用:` | 添加 `必用: false` |
| 错误字段名（`常用`） | 改名为 `必用` |
| `GitHub 链接` 缺失或为 `无` | 联网搜索自动填充；仍找不到则设 `⚠️ Unknown` |
| `GitHub 链接` 为 `⚠️ Unknown` | 保持不动（标记待审，不自动修复） |
| 命名不匹配 | 重命名为 `{NN}-{英文名}.md` |

#### S4: 设备追踪

参照[前置元数据规则](#前置元数据规则)检测当前设备安装状态。

更新 `使用设备:`：

| 安装状态 | 操作 |
|---------|------|
| 已安装 | 在 `使用设备:` 下追加 `- <设备名>` |
| 未安装且 `使用设备:` 为空或无条目 | 设 `使用设备: N/A` |
| 未安装但 `使用设备:` 有来自其他设备的条目 | 保留现有条目不变 |
| 工作流/流程文档/Collection | 设 `使用设备: N/A`（不可安装的软件） |

#### S5: 全局重新排序

对所有目录按 GitHub stars 降序重编号文件：

1. 读取每个文件的 `GitHub Star`；解析：`12K` → 12000，`1.5K` → 1500，`N/A` → 0
2. 按 star 数降序排列（N/A 排末尾）；star 相同则按文件名（去掉 `NN-` 前缀后）字母序
3. 分配新编号 `01`、`02`、`03`……
4. 重命名文件为 `{NN}-{英文名}.md`
5. 修复缺少 frontmatter 字段的文件

#### S6: 报告

展示扫描的目录数、文件数、修复项以及各目录的新编号范围。

#### S7: 数据刷新

对 `辅助工具/` 下每个 `.md` 文件，应用[文档规则](#文档规则)：
- `GitHub Star` — 抓取并更新
- `更新日期` — 设为当天
- `更新功能` — 检查仓库发布日志：有更新 → 追记新条目；无变化 → `"无（数据已同步）"`
- `使用设备` — 重新检测当前设备安装状态

同时询问用户："是否需要联网刷新所有文档的内容？" 确认后对每个文件：
- 抓取 GitHub README 或搜索该工具
- 合并新信息到已有章节
- 如有章节更新则追加到 `更新功能`

无需逐文件确认，批量执行并报告。

### 模板同步工作流

**触发：** `"模板变了"` / `"更新模板"` / `"同步模板"` / `"template changed"` → 执行 T1→T5

模板变更后标准化 frontmatter 字段顺序、字段名称和正文结构。不重编号、不刷新数据、不填充内容——此后运行**同步工作流**处理这些。始终由用户手动触发。

#### T1: 读取模板

1. 读取 `{TEMPLATE}`
2. 解析 frontmatter：记录字段名及其精确顺序
3. 解析正文：识别所有 `##` 章节标题及其顺序
4. 记录与上一个模板版本的差异（新增/删除/重命名字段，新增/删除/重命名章节）

#### T2: 扫描全部知识库文件

遍历 `{VAULT_BASE}` 下所有 `.md` 文件。

#### T3: 逐文件标准化前置元数据

对每个文件应用[前置元数据规则](#前置元数据规则)，外加模板同步专属检查：

| 检查项 | 修复方式 |
|-------|---------|
| 字段名与模板不匹配 | 按模板精确重命名 |
| 字段已从模板移除（如 `tags:`） | 从所有文件删除该字段 |
| 字段已加入模板（如 `使用平台:`） | 以默认值添加该字段 |

**设备检测：** 参照[前置元数据规则](#前置元数据规则)处理每个文件，规则与[同步工作流 S4](#s4-设备追踪)相同。

#### T4: 标准化正文结构

如果模板新增、删除或重排了正文章节：

1. 将每个文件现有章节映射到模板章节顺序
2. 删除模板中已不存在的章节（如 `参考链接`）
3. 从模板新增空白章节（如 `用法`）
4. 按模板顺序重排章节
5. 运行 `scripts/fix-format.sh "{VAULT_BASE}/辅助工具"` — 从 `{TEMPLATE}` 读取各章节结构骨架，将内容包裹到正确的 callout 块、`<details>` 标签或表头中；保留文本内容

#### T5: 确认

告知用户："模板同步完成，共更新 {count} 个文件。"

### 标准化

**触发：** `"标准化所有文档"` / `"全面标准化"` / `"standardize all docs"` — 按顺序执行 修复 → 同步。此为路由别名，非独立工作流。

1. **[修复工作流](#修复工作流)** — 修复格式问题（F1-F3）
2. **[同步工作流](#同步工作流)** — 完整重索引、重编号、设备追踪、数据刷新（S1-S7）

---

### 修复工作流

触发：`"修复文档/修复格式/检查格式/清理"` / `"fix docs"`。扫描知识库发现已知格式问题并修复。不重编号、不刷新数据、不同步模板。

#### F1: 扫描全部知识库文件

遍历 `{VAULT_BASE}` 下所有 `.md` 文件。

#### F2: 检查并修复已知问题

| 检查项 | 检测方式 | 修复方式 |
|-------|---------|---------|
| `aliases` 含 `@` 前缀 | 解析 frontmatter，aliases 值以 `@` 开头 | 移除 `@` 前缀，保留其余文本 |
| `aliases` 少于 3 条或格式不规范 | 英文名含连词符、中文名非分类名、条目数 < 3 | 按[别名规则](#别名规则)修复：英文名去连词符、中文名改为分类名、补核心技术关键词 |
| frontmatter YAML 解析错误 | 解析每个文件的 YAML frontmatter；捕获分隔符/对齐/非法字符等错误 | 修复格式并重新解析直到通过 |
| `ℹ️ 基本介绍` callout 中含裸 `[abstract]`（无 `!`） | `section_has_skeleton` 检测到 >1 行 `[!abstract]` | 运行 `fix-format.sh` — 清理并重新包裹 |
| `ℹ️ 基本介绍` 缺少 `**状态**` 行 | `validate_section_format` 检查 `**状态**` 是否存在 | 运行 `fix-format.sh` — 追加 `> **状态**：<span style="color:var(--color-green)">待评估</span>` |
| `📝 更新功能` 条目描述不规范 | 对照[文档规则](#文档规则)的 `📝 更新功能` 书写规范校验 | 按规则修正 |
| Callout 续行存在前导空格 | `> [!abstract]`/`> [!info]`/`> [!warning]` 后的行以 ` > ` 而非 `> ` 开头 | 移除 `>` 前的空格 |
| 表格后缺少空行再接标题 | `##` 标题紧跟管道行（`|\n##`） | 在表格结尾和下一个 `##` 间插入空行 |
| 末尾缺少 `---` 分隔符 | 文件不以 `---` 结尾 | 追加 `\n---` |
| `💊 痛点解决` 前缺少 `---` 分隔符 | `💊 痛点解决` 前无 `---` 独占一行 | 在 `## 💊 痛点解决` 前插入 `\n---\n` |
| 类型字段不规范 | 缺少、非列表、值无效 | 参照[前置元数据规则](#前置元数据规则)的 `类型:` 检查项修复 |

对每个文件：
- 检测哪些检查项触发
- 应用修复
- 追踪变更内容

#### F3: 报告

按问题类型展示文件数汇总。无问题时如实告知。

### 边界情况

| 情况 | 处理方式 |
|------|---------|
| 无 GitHub 仓库 | 设 `GitHub 链接: ⚠️ Unknown`，`GitHub Star: N/A` |
| Star 数格式不一 | 解析：`12K` → 12000，`1.5K` → 1500，`N/A` → 0 |
| 空白的非模板文件（如 OPENdesign.md） | 跳过——无 frontmatter，非工具文档 |
| 多个文件 star 数相同 | 按工具名字母序排列 |
| 重编号时文件重命名失败 | 停止并报告哪个文件失败 |
| 知识库配置中找不到主机名 | 询问用户当前设备名 |
| 工具安装检测不明确 | 多种方法检测（`which`、`brew list` 等） |
| 跨设备同步 | 知识库同步后（SynologyDrive/其他云盘），设备 B 需重新运行同步工作流更新 `使用设备` 和编号 |

