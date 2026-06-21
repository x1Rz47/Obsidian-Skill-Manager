---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when the 知识库 agent skill documentation needs organizing, renaming, standardizing, fixing, or format-checking. Also use when the 知识库 documentation template changes and all files need syncing to match. Also use when the user says fix docs, fix format, 修复文档, 修复格式, or 检查格式. Compatible with any SKILL.md-based AI coding assistant.
---
<!-- WARNING: All section lists must be read from TEMPLATE.md, never hardcoded. -->

# Obsidian Skill Manager

## Triggering

This skill activates in four modes:

| Mode | Trigger phrases |
|------|----------------|
| **Document** | "记录 [工具]"、"给 [工具] 写个文档"、"doc [tool]" |
| **Deploy** | "安装/下载/部署/install/setup/add/deploy" |
| **Fix** | "修复/检查/同步/清理/模板变了/fix/format/sync/template changed/standardize" |

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

被环境部署和文档修复工作流共享。在其他工作流逻辑前对每个 `.md` 文件执行以下检查：

| 检查项 | 修复方式 |
|-------|---------|
| `字段顺序` 错误 | 按 `{TEMPLATE}` 的 frontmatter 键顺序重新排列 |
| `类型:` 缺失 | 添加为 YAML 列表，取值见[类型规则](#类型规则) |
| `类型:` 非列表 | 转为 YAML 列表：`类型: X` → `类型:\n  - X`；多类型追加全部取值 |
| `使用平台:` 无效 | 通用工具填 `ALL`，Agent 专用工具从 `OpenCode / Codex / Claude Code / Gemini` 中用 ` / ` 分隔选择。禁止 `NO`、`N/A` 等模糊值 |
| `使用设备:` 格式错误 | 修正为 YAML 列表（`  - Device`）或 `N/A` |
| `使用设备:` 缺失 | 检测当前设备安装状态：已安装追加设备名（已有则跳过），未安装设 `N/A` |
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
| `使用设备` | 检测当前设备安装状态：已安装追加设备名（已有则跳过），未安装设 `N/A` |

### 安装检测规则

| 类型 | 检测方式 | 示例 |
|------|---------|------|
| CLI | `which <tool>`（Mac）/ `where.exe <tool>`（Win） | `ffmpeg` |
| brew 包 | `brew list <pkg>`（仅 Mac） | `gh` |
| npm 包 | `npm list -g <pkg>` | `bun` |
| pip 包 | `pip3 list \| grep <pkg>`（Mac）/ `pip list \| findstr <pkg>`（Win） | `openai-whisper` |
| MCP | 同 CLI，按包管理器检测（`which` / `brew list` / `npm list -g` / `pip3 list`） | `MarkItDown` |
| Agent / Skill / Agent-Plugin | 优先 `which <tool>`；无则查各 agent skill 目录（`~/.config/opencode/skills/` / `~/.claude/skills/` / `~/.codex/skills/`） | `BrowserAct` |
| GUI | `ls /Applications/*.app`（Mac）/ `which <tool>` | `OmniVoice-Studio` |
| Web | 不可检测安装状态，永远写 `N/A`（网页应用无本地安装） | `Ian-Xiaohei-Illustrations` |
| Collection / Guide / Model | 不可安装，永远写 `N/A` | `GStack`、`Superpowers` |


## 工作流

### 文档工作流

核心流程：文档管理。处理你发来的链接、工具名、批量或全库更新。

#### I1: 解析输入

根据你提供的内容判断：

| 输入类型 | 处理方式 |
|---------|---------|
| GitHub 链接（`https://github.com/owner/repo`） | 解析工具名、GitHub URL，推断工具类型 |
| 工具名（`ffmpeg` / `Playwright`） | 按名称查知识库 |
| 多个工具（`ffmpeg, git, vscode`） | 解析列表，逐个处理 |
| "所有" / "全部" / 未指定 | 遍历全库，逐个处理 |

#### I2: 搜索匹配

确定目标目录：
- **GitHub 链接** → 按工具类型映射到对应 L1 目录
- **工具名** → 递归搜索 `{VAULT_BASE}/辅助工具/` 下所有 `.md` 文件，按文件名（去掉 `NN-` 前缀）或 `aliases` 匹配
- **多个工具** → 每个工具分别搜索
- **"所有"** → 目标为全库

结果：
- **找到** → I3a 更新文档
- **未找到** → I3b 完整搜资 → 生成文档

#### I3: 更新 / 生成

##### I3a: 已有 → 更新文档

获取当前 GitHub star 数：
- 工具有 GitHub 链接 → 抓取页面解析 star 数
- 抓取失败或没有 GitHub 仓库 → 保留原有 `GitHub Star`

然后应用[文档规则](#文档规则)：
- 同步 GitHub star、更新日期
- 检查仓库发布日志：有更新 → 追记 `- YYYY-MM-DD：新功能摘要`；无变化 → `"无（数据已同步）"`
- 用户提供了新信息 → 优先合并用户内容

---

##### I3b: 无文档 → 完整搜资 → 生成文档

收集以下信息：
- 官方 README / 文档中的简介
- GitHub 链接和 star 数（用搜索引擎或 GitHub API）
- 安装命令
- 核心功能、依赖项、`使用平台`
- 注意事项或已知限制

GitHub 抓取失败时设 `GitHub Star: N/A`。

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

#### I4: 报告

汇总本次操作：

| 指标 | 数值 |
|------|------|
| 新建文件 | {n} |
| 更新文件 | {n} |
| 无变更 | {n} |
| GitHub Star 变化 | 列出变化项 |

如全库更新则按目录分组展示。

### 环境部署工作流

#### D1: 解析指令

| 你说 | 行为 |
|------|------|
| `安装所有` / `安装`（未指定类型） | `必用: true` |
| `安装 <类型>`（如 `安装 MCP` / `安装 skills` / `安装 CLI`） | `必用: true` + `类型` 含指定值 |

#### D2: 确定设备 + 扫描匹配

1. 确定当前设备：
   - 读 `SKILL.local.md`，取当前主机名（`hostname -s`）
   - 从设备配置表查到 `{VAULT_BASE}` 路径
   - 找不到则询问用户主机名和路径
2. 递归遍历 `{VAULT_BASE}/辅助工具/` 下所有 `.md` 文件，解析 frontmatter
3. 扫描时检测 frontmatter 问题：字段缺失、顺序错误、格式异常。发现问题当场报告并提示"建议运行文档修复工作流"，**不自动修复**
4. 按 D1 条件过滤：
   - **安装所有** → `必用: true`
   - **安装 <类型>** → `必用: true` + `类型` 含指定值
5. 无匹配则报告并停止

#### D3: 选择并安装

1. 对每个匹配的文件按[安装检测规则](#安装检测规则)检测安装状态，展示汇总表：

   | 工具名 | 类型 | 状态 |
   |--------|------|------|
   | ffmpeg | CLI | ✅ 已安装 |
   | BrowserAct | Agent | ❌ 未安装 |

   "共 {n} 个工具，{x} 个已安装，{y} 个未安装"
   若全部已安装则报告并停止。

2. 展示未安装的工具多选列表，让你勾选要安装的
3. 逐个安装选中的工具：
   - 工具原文档有安装命令 → 直接按文档执行
   - 文档无安装命令 → 联网搜索官方安装文档
4. 安装后执行验证：重新运行[安装检测规则](#安装检测规则)确认成功
   - 失败 → 询问"是否重试该工具"，是则重新安装当前工具，否则跳过并记入报告
5. 成功后更新 `使用设备`：追加当前设备名（已有则跳过；原为 `N/A` 则替换）
6. 记录每个工具的结果

#### D4: 报告

按结果展示每项的安装明细：

| 工具名 | 类型 | 结果 | 说明 |
|--------|------|------|------|
| ffmpeg | CLI | ✅ 成功 | which ffmpeg 验证通过 |
| BrowserAct | Agent | ❌ 失败 | 复制失败：无写入权限 |
| yt-dlp | CLI | ⏭️ 跳过 | 未勾选 |
| Superpowers | Collection | ➖ 不可安装 | 类型不支持安装 |

汇总："{n} 个工具：{s} 个成功，{f} 个失败，{k} 个跳过"
失败的工具询问"是否重试"或"跳过"。

### 文档修复工作流

触发：`"文档有问题"` / `"修复文档"` / `"修复格式"` / `"检查格式"` / `"fix format"` / `"格式乱了"` / `"文档坏了"` / `"模板变了"` / `"更新模板"` / `"同步模板"` / `"template changed"` / `"标准化所有文档"` / `"全面标准化"` / `"standardize all docs"`。

文档格式出问题时执行。覆盖模板同步、格式修复、内容补充三件事。

- 触发词含 `模板` → 全库模式，跳过 F4（仅结构对齐，不补内容）
- 其他触发词 → 按 F1 确定范围

#### F1: 确定范围

根据用户指令判断：
- **用户指定了路径** → 判断是文件还是目录：
  - 相对路径以 `{VAULT_BASE}` 为基准解析
  - 目录则递归该目录下所有 `.md` 文件
- **用户未指定**（如 `修复格式` / `文档有问题`）→ 遍历 `{VAULT_BASE}` 下所有 `.md` 文件

#### F2: 模板同步

对范围内的每个文件：读取模板（首次执行时），按模板对齐字段名（新增/删除/重命名字段）、章节结构（新增/删除/重排章节），然后运行 `fix-format.sh` 修复骨架。

模板同步失败的文件标记为 `⚠️ 模板异常`，跳过 F3-F4。

#### F3: 格式修复

对范围内的每个文件，按以下模块依次检查并修复：

**模块 A — 前置元数据**

| 检查项 | 检测方式 | 修复方式 |
|-------|---------|---------|
| 字段缺失 | 对照模板字段列表（aliases/类型/GitHub 链接/GitHub Star/使用设备/使用平台/创建日期/更新日期/必用），检查是否存在 | 按模板补全缺失字段 |
| 字段顺序不对 | 检查排列顺序 | 按模板顺序重排 |
| 字段格式错误 | 日期非 `YYYY-MM-DD`、`GitHub Star` 格式不对、`必用` 非布尔值 | 按[前置元数据规则](#前置元数据规则)修复格式 |
| 字段内容缺失 | `GitHub 链接` 为 `无`/空、`GitHub Star` 为空 | 标记为 `⚠️ 待补齐`，由 F4 联网搜索修复 |
| `aliases` 含 `@` 前缀 | YAML 解析，值以 `@` 开头 | 移除 `@` |
| `aliases` 少于 3 条或格式不规范 | 条目数 < 3、英文名含连词符、中文名非分类名 | 按[别名规则](#别名规则)修复 |
| `类型` 不规范 | 缺少、非列表、值无效 | 按[类型规则](#类型规则)修复 |
| `使用平台` 无效 | 通用工具非 `ALL`、Agent 工具非平台列表 | 按[前置元数据规则](#前置元数据规则)修复 |
| `使用设备` 缺失/格式错 | 非 YAML 列表也非 `N/A` | 按[前置元数据规则](#前置元数据规则)修复 |
| 布尔值未小写 | `True`/`False`/`Yes`/`No` | 修正为小写 |
| YAML 解析错误 | 解析 frontmatter 报错 | 修复格式直到通过 |

**模块 B — 正文结构**

| 检查项 | 检测方式 | 修复方式 |
|-------|---------|---------|
| 各节 callout/骨架异常 | 检测模板各节的预期骨架（`[!abstract]`、`[!info]`、`[!warning]`、`<details>`、表格、列表） | 运行 `fix-format.sh` 统一修复 |
| `📝 更新功能` 格式不规范 | 非 `- YYYY-MM-DD：（全角冒号）` 条目格式 | 按[文档规则](#文档规则)修正 |

**模块 C — Markdown 格式**

| 检查项 | 检测方式 | 修复方式 |
|-------|---------|---------|
| Callout 续行前导空格 | `> [!...]` 后的行以 ` > ` 开头 | 移除 `>` 前的空格 |
| 表格后缺空行再接标题 | `##` 紧跟 `|\n` | 补空行 |
| 文件不以 `---` 开头 | 首行非 `---` | 补 frontmatter 分隔符 |
| `💊 痛点解决` 前缺 `---` | 前无 `---` 独占行 | 补插 |
| 末尾缺 `---` | 文件不以 `---` 结尾 | 追加 |
| 空行模式不匹配模板 | 检测全文档：frontmatter 后、分隔符前后、`##` 前后、末尾 `---` 前不是恰好 1 空行，或出现连续空行 | 按模板归一化：每对相邻结构元素之间恰好 1 空行，无连续空行 |

对范围内的每个文件：文件不以 `---` 开头时优先修复 frontmatter 分隔符，再按 A → B → C 顺序检测其余项 → 应用修复 → 追踪变更。

#### F4: 内容补充

- **模板类触发词** → 跳过 F4（仅结构对齐）
- **其他触发词** → 询问用户"是否需要联网搜索补齐空白章节？"
  - **拒绝** → 跳过 F4，直接进入 F5
  - **同意** → 对范围内的每个文件：

1. **检测空白章节**：对照模板章节结构，找出内容为空或仅有占位符（如 `待补充`、`TBD`、空 callout）的章节
2. **搜索补齐**：按优先级搜索——GitHub README > 官网文档 > 通用 web 搜索
   - 根据工具名/分类判断语言偏好，优先匹配语言结果
   - 只填充空白/占位章节，不覆盖已有内容
3. **搜索失败**：保留原样，在报告中标记为 `⚠️ 未找到`
4. **网络中断**：已补齐的文件保留，未补齐的标记 `⚠️ 未找到`

#### F5: 报告

- **指定文件时**：列出每项的修复明细——`{文件}: A:{n}项 B:{n}项 C:{n}项 F4:补齐{n}章 ⚠️:模板异常{n} | 未找到{n} | 待补齐{n}`
- **全库时**：按问题类型展示文件数汇总

无问题时如实告知。

报告中也列出本次修复中产生的所有标记状态（`⚠️ 待补齐` / `⚠️ 模板异常` / `⚠️ 未找到`），供其他工作流参考。

### 边界情况

| 工作流 | 情况 | 处理方式 |
|-------|------|---------|
| 通用 | 知识库配置中找不到主机名 | 询问用户当前设备名 |
| 通用 | 工具安装检测不明确 | 按优先级检测：`which` → `brew list` → `npm list -g` → `pip3 list` |
| 通用 | 文件被占用无法读写 | 跳过该文件，报告 `⚠️ 文件锁定`，提示用户关闭后重试 |
| 通用 | GitHub API 限速 / 联网失败 | 暂停 60 秒重试；失败 3 次则标记 `⚠️ 网络异常`，跳过联网步骤 |
| 通用 | 文件名含非法字符 | 按[命名规则](#命名规则)过滤非法字符 |
| 通用 | `{VAULT_BASE}` 路径不存在 | 提示用户检查 `SKILL.local.md` 路径配置 |
| 通用 | `{TEMPLATE}` 文件缺失 | 提示用户重新安装 skill |
| 通用 | 知识库目录无 `.md` 文件 | 报告"未找到任何文档"，停止执行 |
| 通用 | GitHub Star 为 0 | `0` 按数字 0 排序（小于所有正数），`N/A` 排末尾 |
| 文档修复 | 跨设备同步 | 知识库同步后（SynologyDrive/其他云盘），设备 B 需运行文档修复工作流更新 `使用设备` 等字段 |

以上边界情况在所有工作流中通用。

