---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when the vault's skill documentation needs organizing, renaming, or standardizing. Also use when the vault documentation template changes and all files need syncing to match.
template_hash: 46df8d3e430e027259091040fbf9bd35
template_checked: 2026-06-18
---

# Obsidian Skill Manager

## Overview

Seven workflows:

**Install:** When installing a new tool, check vault for existing docs (skip if found), install it, and mark the device. Does not modify vault files.

**Document:** When recording a tool, scan vault for existing docs (update if found, create if new), gather info, and generate an Obsidian document. Does not install anything.

**Combined:** Install first, then document if no existing doc was found.

**Deployment:** Scan vault for `必用: true` tools and install them on the current device.

**Fix:** Scan vault for known format issues and fix them — no template sync, no data refresh, no renumbering.

**Sync:** Full vault scan — fix numbering, validate frontmatter, update device tracking, re-sort by stars.

**Template Sync:** When the vault template changes, propagate new field order, section structure, and defaults to every file.

## Triggering

This skill activates in six modes:

| Mode | Trigger phrases |
|------|----------------|
| **Install** | "安装/下载 [工具]"、"install/setup/add [tool]" |
| **Document** | "记录 [工具]"、"给 [工具] 写个文档"、"doc [tool]" |
| **Combined** | "安装并记录 [工具]"、"install and doc [tool]" |
| **Deployment** | "部署/安装必用/安装常用/同步技能"、"deploy/setup this machine" |
| **Fix** | "修复文档/修复所有文档/修复格式/检查格式"、"fix docs/fix format" |
| **Sync** | "执行/同步/清理"、"sync/clean up/reindex" |
| **Template Sync** | "模板变了/更新模板/同步模板/更新所有文档/刷新所有文档"、"template changed/sync template/refresh all docs" |

## Vault Configuration

`hostname` determines the active config:

```
if hostname == "x1Rz47-A1213":    # Mac Mini (macOS)
  VAULT_BASE = /Users/x1rz47/Library/CloudStorage/SynologyDrive-x1Rz47/5.个人资料/1.知识库/个人知识库/04.AI相关-🤖
  TEMPLATE   = {VAULT_BASE}/00-工具功能介绍模板.md
elif hostname == "WPC-x1Rz47":    # WPC (Windows)
  VAULT_BASE = D:\SynologyDrive\5.个人资料\1.知识库\个人知识库\04.AI相关-🤖
  TEMPLATE   = {VAULT_BASE}\00-工具功能介绍模板.md
else:
  ask user to identify the device and add to [Device Configuration](#device-configuration)
```

## Category Directories

See [Sync S2 table](#step-s2-scan-all-vault-directories) for the canonical directory list and numbering rules.

## Classification Guide (Skills vs 工具 vs 插件 vs MCP)

### 核心原则

按 **执行上下文** 分类：工具运行在 Agent **外部**（独立可执行）还是 **内部**（注入 Agent 运行时）？

### Phase 1: 预判（安装前）

```
看 GitHub 仓库描述 / README 首段 / README.md 标题（按优先级）：
┌─ 含 "MCP server" / "Model Context Protocol" / 包名含 -mcp 后缀 → MCP/
├─ 含 "skill" / "agent skill" / "opencode skill"
│  或仓库根目录有 SKILL.md（YAML frontmatter + ## 触发条件）
│  ├─ 单 skill（npx skills add owner/repo@skill）                   → Skills/
│  └─ 多 skill 包（npx skills add owner/repo）                       → Skills-Packs/
├─ 运行在 Agent 内部但非 SKILL.md 形式
│  ├─ 注入 Agent 运行时 / 描述含 "plugin" / "inject into agent"  → 插件/
│  └─ 以 MCP 协议形式接入（配置在 opencode.jsonc mcpServers）        → MCP/
└─ 以上都不匹配 → 默认进入 工具/ 类别：
    ├─ 独立 CLI / 库 / Obsidian 插件 / VS Code 扩展 / 下载的二进制  → 工具/
    └─ 不明 → 问用户："这个工具运行在 Agent 内部还是外部？"
```

**判断 插件/ vs 工具/ 的辅助规则：**

| 特征 | → | 例子 |
|------|---|------|
| 安装后修改了 Agent 的行为/能力（记忆/编辑加速/类型检查/脱敏） | **插件/** | supermemory, morph, type-inject, vibeguard |
| 安装后独立可执行，Agent 不依赖它 | **工具/** | yt-dlp, repomix, deepagents, agent-browser |
| 描述含 "plugin" / "inject into agent"（注入 Agent 运行时，不论平台） | **插件/** | oh-my-openagent, vibeguard |
| 描述含 "Obsidian community plugin"、"standalone CLI" | **工具/** | Defuddle |
| 安装到 `~/.opencode/plugins/` 或类似 Agent 插件目录 | **插件/** | — |
| Obsidian 插件 / VS Code 扩展 | **工具/** | 运行在 Agent 外部，不修改 Agent 行为 |

### Phase 2: 验证（安装后）

| Phase 1 | 实际在 Agent 外部 | 实际在 Agent 内部 |
|---------|-----------------|------------------|
| **工具/** | ✅ 一致 | ❌ 冲突 → 标记复核 |
| **插件/** | ❌ 冲突 | ✅ 一致 |
| **Skills/** | ❌ 冲突 | ✅ 取决于具体形式 |
| **MCP/** | — | 检查 opencode.jsonc → ✅ |

冲突时标记 `⚠️ 分类存疑，需人工确认`，不自动纠正。

### Concrete Rules

| 类型 | 运行位置 | 识别方式 | 例子 |
|------|---------|---------|------|
| **MCP Server** | Agent 内部（协议） | 描述含 "MCP server" / "Model Context Protocol"；包名含 `-mcp` | MarkItDown-MCP, CodeGraph, GBrain |
| **Agent Skill** | Agent 内部（指令集） | 描述含 "skill"；仓库有 SKILL.md + 触发条件；安装：npx skills add | Playwright-skill, BrowserAct-skill, Find-Skills, Agent-Reach |
| **Skill Pack** | Agent 内部（指令集） | 多 skill 仓库；安装：npx skills add owner/repo | Superpowers, Anthropic, MattPocock, GStack |
| **插件** | Agent 内部（运行时注入） | 描述含 "plugin" / "inject into agent"；安装后修改 Agent 能力，不论针对哪个平台 | oh-my-openagent, supermemory, type-inject, morph |
| **工具** | Agent **外部** | 以上都不符合的可安装软件，不论具体形态 | yt-dlp, repomix, deepagents, agent-browser, Defuddle |

> **工具/ 是兜底分类。** 只要不是 MCP server、不是 agent skill、也不是注入 Agent 运行时的插件，全部归入 工具/。Obsidian 插件、VS Code 扩展、OpenCode 插件中不注入运行时的部分，都是 工具/。

### Directory Depth Rule

**Skills/ 下避免 3 级目录**（最多 2 级）。只有当某个二级分类下有 **≥3 个文件** 且子类之间领域明显不同时，才保留 3 级：

| 场景 | 做法 |
|------|------|
| 三级目录仅 1-2 个文件 | 拍平到二级 |
| 三级目录 ≥3 个文件，且子类不同 | 保留三级，如 `媒体创作/视频制作/` + `内容创作/` |
| 三级目录 3+ 文件但子类相近 | 考虑拍平 |

Skills-Packs 按技能包来源划分，不受此限。

### Key Discriminators（速查卡）

| 问题 | → |
|------|----|
| 运行在 Agent **外部**（独立可执行，不依赖 Agent 运行时）？ | **工具/** |
| 运行在 Agent **内部**，以 SKILL.md 指令集形式？ | **Skills/** 或 **Skills-Packs/** |
| 运行在 Agent **内部**，以注入运行时插件形式？ | **插件/** |
| 运行在 Agent **内部**，以 MCP 协议工具形式？ | **MCP/** |
| 仓库描述含 "MCP server" / "Model Context Protocol" | **MCP/** |
| 仓库有 SKILL.md + 触发条件 | **Skills/** |
| 安装命令是 `npx skills add` | **Skills/** |
| 描述含 "plugin" / "inject into agent" / 安装到 Agent 插件目录（运行时注入，不论平台） | **插件/** |
| 描述含 "Obsidian plugin" / "standalone CLI" / "library" / "framework" / "package" | **工具/** |
| 以上都不明确 | **问用户** |

### Known Misclassifications（反面教材）

| 文件 | 错放在 | 原因 | 正确分类 |
|------|--------|------|---------|
| `Agent-Browser.md` | Skills/ | `vercel-labs/agent-browser` 是独立 npm CLI（36K），运行在 Agent 外部 | **工具/** |
| `Repomix-Explorer.md` | Skills/ | `yamadashy/repomix` 是独立 npm CLI（2.4K），运行在 Agent 外部 | **工具/** |
| `Deep-Agents.md` | Skills/ | `langchain-ai/deepagents` 是独立 Python 框架（24.6K），运行在 Agent 外部 | **工具/** |
| `SkillOpt.md` | Skills/ | `microsoft/SkillOpt` 是独立 pip 工具（7.1K），运行在 Agent 外部 | **工具/** |
| `Defuddle.md` | 插件/ 或 Skills/ | `kepano/defuddle` 是 Obsidian 插件（7K），运行在 Agent **外部** | **工具/** |

## Device Configuration

| Hostname | Device Name |
|----------|-------------|
| `x1Rz47-A1213` | Mac Mini |
| `WPC-x1Rz47` | WPC |

## 使用设备 判定规则

`使用设备` 记录工具**在当前设备上是否实际安装**，不是"依赖存在"或"相关应用已安装"。

| 工具类型 | 判定命令 | 示例 |
|---------|---------|------|
| agent skill | `npx skills list -g` 可见 或 目录存在 | `video-use` |
| MCP server | `opencode.jsonc` 的 `mcpServers` 中已配置 | `markitdown-mcp` |
| CLI 工具 | `which <tool>`（Mac）/ `where.exe <tool>`（Win） | `ffmpeg` |
| brew 包 | `brew list <pkg>`（仅 Mac） | `gh` |
| npm 全局包 | `npm list -g <pkg>` | `bun` |
| pip 包 | `pip3 list \| grep <pkg>`（Mac）/ `pip list \| findstr <pkg>`（Win） | `openai-whisper` |
| 工作流/Skills-Packs | 不可安装，永远写 `N/A` | GStack, Superpowers |

**禁止：**
- Obsidian App 已安装 ≠ `kepano/obsidian-skills` 的 skill 已安装
- 电脑有 ffmpeg ≠ `manim` Python 包已安装
- 依赖存在 ≠ 工具本身存在

## Naming Conventions

All skill document filenames in the vault must follow:

**Format:** `{NN}-{English-Name}.md`
- `NN`: 2-digit number (`01`, `02`...`99`)
- `English-Name`: Pascal-kebab-case, English only
- Example: `12-Playwright.md`, `04-Data-Visualization.md`

**Rules:**
- Only letters, numbers, and hyphens allowed
- First letter of each word capitalized (Pascal case), joined by hyphens
- No Chinese characters, no spaces, no underscores, no special characters
- No category suffix: Do not append category type (e.g., `-mcp`, `-plugin`, `-skill`) to filename — the directory path already indicates the type
- Strip vendor prefix: Remove redundant vendor/framework prefixes (e.g., `opencode-X` → `X`, `vscode-X` → `X`) unless the prefix is part of the tool's official identity
- Template files (`00-*`) are excluded from the numbering convention

**Independent numbering per directory (including 3rd-level subdirectories):** See [Sync S2 table](#step-s2-scan-all-vault-directories) for the canonical directory list and numbering rules. When moving or renaming files, always parse frontmatter `工具名` and convert to Pascal-kebab-case.

## Common Pre-Check (Step 0: Template Hash Validation)

Before ANY workflow (Install, Document, Combined, Deployment, Sync, Template Sync), check if the vault template has changed:

### Step 0.1: Compute Current Template Hash

Run the appropriate command for the current OS to get the MD5 hash of `{TEMPLATE}`:
- **Mac:** `md5 -q "{TEMPLATE}"`
- **Windows:** `certutil -hashfile "{TEMPLATE}" MD5 | findstr /v "MD5"`

### Step 0.2: Compare with Stored Hash

Read `template_hash` from this SKILL.md's frontmatter:
- If hashes **match** → template unchanged, proceed to the requested workflow
- If hashes **differ** → template has been modified since last sync:
  1. Report the hash difference to the user
  2. Ask: "模板已更新，是否同步所有文档到新模板格式？"
  3. **User confirms** → abort current workflow, switch to **Template Sync Workflow** (Step T1-T5). After Template Sync completes, `template_hash` is automatically updated.
  4. **User declines** → update `template_hash` in SKILL.md frontmatter to the current hash without syncing. Continue with the requested workflow.

### Step 0.3: Update Timestamp

If `template_checked` is more than 7 days old, update it to today.

## Install Workflow（安装，不动 vault）

### Step I1: Identify the Tool

Determine:
- **Name**: What is it called?
- **Type**: skill / 插件 / MCP / npm package / config / other
- **Source**: GitHub / npm / brew / pip / direct download
- **Category**: Map source to target directory using the [Sync S2 table](#step-s2-scan-all-vault-directories).

### Step I2: Gather Information

Collect:
- Description from official docs/README
- GitHub URL and star count (use web search)
- Installation command
- Core features
- Dependencies
- Any warnings or notes

If GitHub fetch fails (network error, no GitHub repo), set `GitHub星标: N/A`. Do not block the workflow.

### Step I3: Check for Existing Document

Before installing, scan the target directory in vault:
1. Read all files in the target category directory
2. Parse frontmatter of each file for `工具名` and `aliases`
3. If a match is found → tell the user: "该工具已记录过文档，不再重复记录"
4. If no match → proceed (Document workflow will handle it if needed)

Continue to install regardless of the result.

### Step I4: Execute Installation

Run the installation command. Wait for it to complete. Verify success.

After installation, note the current device name from Device Configuration. Device detection follows the [使用设备 判定规则](#使用设备-判定规则) table.

---

## Document Workflow（记录，不安装）

### Step W1: Check for Existing Document

1. Read all files in the target category directory
2. Parse frontmatter of each file for `工具名` and `aliases`
3. If a match is found → this is an **UPDATE**:
   - Update `更新日期` to today
   - Do NOT modify `创建日期`
   - Add a new entry to `更新功能`: e.g. "更新于 2026-06-06: 更新了核心功能描述"
   - Merge new information into existing sections
   - Do NOT change the file's number
   - Skip Steps W3-W4, go directly to save
4. If no match → this is a **NEW** entry, proceed to Step W2

### Step W2: Gather Information

Collect:
- Description from official docs/README
- GitHub URL and star count (use web search)
- Core features
- Dependencies
- Any warnings or notes

### Step W3: Global Sort and Renumber (NEW entries only)

Follow [Sync Step S5](#step-s5-global-re-sort) for the target directory only.

### Step W4: Generate Obsidian Document

Read the template file at `{TEMPLATE}`, then fill in each section:

**Frontmatter:**
```yaml
---
工具名: <tool-name>
aliases:
  - <alias-1>
  - <alias-2>
标签:
  - <type-tag>
  - <domain-tags>
GitHub连接: <github-url>
GitHub星标: <star-count>
创建日期: <today>  # 设置后永不更改
更新日期: <today>  # 每次修改文档时更新到当天
必用: false
使用设备:
  - Mac Mini
使用平台: 全平台
---
```

**Field order must match the template exactly:**
```
工具名 → aliases → 标签 → GitHub连接 → GitHub星标 → 创建日期 → 更新日期 → 必用 → 使用设备 → 使用平台
```

**`GitHub连接` must always be populated:**
- When installing via `npx skills add owner/repo@skill` → derive from `owner/repo` → `https://github.com/owner/repo`
- When installing via `npm install owner/repo` → derive from `owner/repo`
- When the install URL is known from the user or the skill source → write it directly
- NEVER leave `GitHub连接` as `无` or empty — if truly unknown, set to `⚠️ Unknown` (not `无`)
- Cross-check against the [Known Repo Mapping](#known-repo-mapping) table below

**Device detection:** Follow the [使用设备 判定规则](#使用设备-判定规则) table to determine install status per device.

**When verifying a file's frontmatter:**
- `必用:` controls deployment behavior (`必用: true` = deploy to new devices)
- `使用设备:` tracks actual installation per device (not intent)

**Sections to fill:**
- **Skills简介** — 1-2 sentences summarizing what it does
- **包含技能** — (技能包专用) 子技能列表
- **触发条件** — 什么情况下触发
- **前置依赖** — 需提前安装的依赖
- **主要解决的问题** — ❌/✅ format, at least 3 pain points
- **核心功能** — ### headers with feature descriptions
- **主要使用场景** — Bullet list with **bold** scene names
- **常用命令/语法** — Code blocks with actual commands
- **注意事项** — Important caveats
- **更新功能** — changelog entries at the bottom

Write to `{VAULT_BASE}/{category}/{filename}`.
Confirm to the user that the tool is documented.

---

## Combined Workflow（安装并记录）

1. Run [Install Workflow](#install-workflow安装不动-vault) Steps I1-I4
2. After installation, if no existing document was found in Step I3, run [Document Workflow](#document-workflow记录不安装) Steps W2-W4 (skip W1, info was already gathered in I2)

## Deployment Workflow（部署必用工具）

Scan the vault for `必用: true` tools and install them on the current device.

### Step D1: Scan for Favorites

1. Read all .md files in `{VAULT_BASE}/辅助工具/Skills/` (all subdirectories)
2. Parse frontmatter of each file, filter for `必用: true`
3. If none found, report "没有标记必用的工具" and stop

### Step D2: Install Each Favorite

For each file with `必用: true`:

1. Read the document body, focusing on the **常用命令/语法** and **核心功能** sections
2. Infer the installation command(s) from the content
3. Determine what to install:
   - **System tool** (brew/pip/npm) → run the install command directly
   - **OpenCode skill** → create `~/.config/opencode/skills/{tool-name}/SKILL.md`
4. Check if already installed — skip if present
5. Execute the install command. Verify success.
6. Record success or failure

### Step D3: Report Results

Present a summary table:

| Tool | Status |
|------|--------|
| Find-Skills | ✅ 已完成 |
| Data-Visualization | ✅ 已完成 |
| Task-Management | ⏭️ 已存在 |

## Sync Workflow (Clean and Re-Sort)

This workflow runs independently. Use it when you've manually added, deleted, or renamed files in the vault, and need the numbering restored to a consistent state across all directories.

### Step S1: Determine Current Device

1. Run `hostname` to get the current machine's hostname
2. Look up the device name in the Device Configuration table
3. If the hostname is not mapped, ask the user to identify the device

### Step S2: Scan All Vault Directories

Walk ALL `.md` files under `{VAULT_BASE}` (excluding `00-工具功能介绍模板.md`) grouped by directory:

| Directory | Numbering Rule | Frontmatter Required |
|-----------|---------------|---------------------|
| `辅助工具/Skills/浏览器自动化/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/媒体创作/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/搜索代理/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/效率工具/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/启动验证/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/知识管理/Obsidian生态/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/知识管理/个人效能/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/规划/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/执行/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/协作/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/工作流/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/质量/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/01-Superpowers/元技能/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/02-Anthropic/API与开发/` | Manual (01-N, ordered by stars) | Full template |
| `辅助工具/Skills-Packs/02-Anthropic/文档处理/` | Manual (01-N, ordered by stars) | Full template |
| `辅助工具/Skills-Packs/02-Anthropic/创意设计/` | Manual (01-N, ordered by stars) | Full template |
| `辅助工具/Skills-Packs/02-Anthropic/沟通协作/` | Manual (01-N, ordered by stars) | Full template |
| `辅助工具/Skills-Packs/03-MattPocock/工程开发/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/03-MattPocock/工作效率/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/03-MattPocock/其他/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/04-GStack/{category}/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/05-Awesome-Copilot/` | Manual (01-N, ordered by stars) | Full template |
| `辅助工具/MCP/` | By GitHub stars (desc) | Full template |
| `辅助工具/工具/` | By GitHub stars (desc) | Full template |
| `辅助工具/插件/` | By GitHub stars (desc) | Full template |

For each file, parse its frontmatter and build a manifest: `工具名`, `GitHub星标`, `使用设备`, `必用`, and install commands.

### Step S3: Detect and Fix Issues Per File

For every file across all directories:

- **Missing `使用设备:`** → Add with current device name or `no`
- **Wrong `使用设备:` format** → YAML list (`  - DeviceName`) or `使用设备: N/A`
- **Missing `必用:`** → Add `必用: false`
- **Wrong field name (`常用`)** → Rename to `必用`
- **Wrong field order** → Reorder to match template: `工具名` → `aliases` → `标签` → `GitHub连接` → `GitHub星标` → `创建日期` → `更新日期` → `必用` → `使用设备` → `使用平台`
- **Stale fields (`tags:`)** → Remove (template doesn't have it)
- **`GitHub连接` missing or `无`** → Auto-fill from Known Repo Mapping table (see below); if no match found, set to `⚠️ Unknown`
- **`GitHub连接` is `⚠️ Unknown`** → Leave as-is (flagged for review, don't auto-fix without confirming)
- **Naming mismatches** → Rename to `{NN}-{Pascal-Kebab-Name}.md`
- **Malformed frontmatter** → Fix YAML formatting (e.g. comma-separated→list, empty values→N/A, wrong field names)

#### Known Repo Mapping

Used by Document Workflow Step W4 and Sync S3 — extend as new tools are installed.
Kept in global copy at `~/.config/opencode/skills/obsidian-skill-manager/SKILL.md` so all sessions benefit.

| 工具名 (`工具名`) | GitHub Repo |
|---|---|---|
| `Agent Browser` / `agent-browser` | `https://github.com/vercel-labs/agent-browser` |
| `Agent Reach` / `agent-reach` | `https://github.com/Panniantong/Agent-Reach` |
| `AISuite` / `aisuite` | `https://github.com/andrewyng/aisuite` |
| `AiToEarn` / `ai-to-earn` | `https://github.com/yikart/AiToEarn` |
| `BrowserAct` / `browser-act` | `https://github.com/browser-act/skills` |
| `Cheat on Content` / `cheat-on-content` | `https://github.com/XBuilderLAB/cheat-on-content` |
|content` |
| `Chronos` / `chronos-forecasting` | `https://github.com/amazon-science/chronos-forecasting` |
| `CodeGraph` / `codegraph` | `https://github.com/colbymchenry/codegraph` |
| `Data Visualization` / `data-visualization` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Deep Agents` / `deep-agents` | `https://github.com/langchain-ai/deepagents` |
| `Defuddle` / `defuddle` | `https://github.com/kepano/defuddle` |
| `Douyin to Text` / `douyin-to-text` | `https://github.com/bibigod/douyin-to-text` |
| `Find Skills` / `find-skills` | `https://github.com/vercel-labs/skills` |
| `GBrain` / `gbrain` | `https://github.com/garrytan/gbrain` |
| `Goal Prompt Builder` / `goal-prompt-builder` | `https://github.com/win4r/goal-prompt-builder` |
| `Last30Days` / `last30days` | `https://github.com/mvanhorn/last30days-skill` |
| `Last30Days CN` / `last30days-cn` | `https://github.com/Jesseovo/last30days-skill-cn` |
| `Manim Video` / `manim-video` | `https://github.com/obra/superpowers` |
| `MarkItDown` / `markitdown` | `https://github.com/microsoft/markitdown/tree/main/packages/markitdown-mcp` |
| `Memory Management` / `memory-management` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Obsidian Bases` / `obsidian-bases` | `https://github.com/kepano/obsidian-skills` |
| `Obsidian CLI` / `obsidian-cli` | `https://github.com/kepano/obsidian-skills` |
| `Obsidian Markdown` / `obsidian-markdown` | `https://github.com/kepano/obsidian-skills` |
| `Obsidian Skill Manager` / `obsidian-skill-manager` | `https://github.com/x1Rz47/Obsidian-Skill-Manager` |
| `Oh My Openagent` / `oh-my-openagent` | `https://github.com/code-yeongyu/oh-my-openagent` |
| `OpenCode Supermemory` / `opencode-supermemory` | `https://github.com/supermemoryai/opencode-supermemory` |
| `OpenMontage` / `openmontage` | `https://github.com/calesthio/OpenMontage` |
| `Playwright` / `playwright-skill` | `https://github.com/testdino-hq/playwright-skill` |
| `Repomix Explorer` / `repomix-explorer` | `https://github.com/yamadashy/repomix` |
| `SkillOpt` / `skillopt` | `https://github.com/microsoft/SkillOpt` |
| `SkillSpector` / `skillspector` | `https://github.com/NVIDIA/SkillSpector` |
| `Startup Pressure Test` / `startup-pressure-test` | `https://github.com/Kappaemme-git/codex-startup-pressure-test-skill` |
| `Synapse` / `synapse` | `https://github.com/akillness/synapse-skill` |
| `Task Management` / `task-management` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Technical Documentation` / `technical-documentation` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Video Use` / `video-use` | `https://github.com/obra/superpowers` |
| `Yt-Dlp` / `yt-dlp` | `https://github.com/yt-dlp/yt-dlp` |
| (All `mattpocock/skills` skills — 工程开发 12) | `https://github.com/mattpocock/skills` |
| (All `mattpocock/skills` skills — 工作效率 5) | `https://github.com/mattpocock/skills` |
| (All `mattpocock/skills` skills — 其他 4) | `https://github.com/mattpocock/skills` |
| (All `anthropics/skills` skills) | `https://github.com/anthropics/skills` |
| (All `addyosmani/agent-skills` skills) | `https://github.com/addyosmani/agent-skills` |
| (All `vercel-labs/skills` skills) | `https://github.com/vercel-labs/skills` |
| (All `kepano/obsidian-skills` skills) | `https://github.com/kepano/obsidian-skills` |
| (All `obra/superpowers` skills) | `https://github.com/obra/superpowers` |
| (Add rows as new tools are installed)

### Step S4: Device Tracking

Follow [使用设备 判定规则](#使用设备-判定规则) to detect each tool's install status on the current device.

Update `使用设备:` per file:

| Install Status | Action |
|---------------|--------|
| Tool IS installed | Add `  - <DeviceName>` under `使用设备:` |
| Tool NOT installed and `使用设备:` is empty or has no entries | Set `使用设备: N/A` |
| Tool NOT installed but `使用设备:` has entries from other devices | Leave existing entries unchanged |
| Workflow/process doc / Skills-Packs | Set `使用设备: N/A` (not installable software)

### Step S5: Global Re-Sort

For all directories sorted by GitHub stars, renumber files:

1. Read `GitHub星标` from each file; parse counts: `12K` → 12000, `1.5K` → 1500, `N/A` → 0
2. Sort by star count descending (N/A → end); equal stars → alphabetically by `工具名`
3. Assign new numbers `01`, `02`, `03`...
4. Rename files to `{NN}-{Pascal-Kebab-Name}.md`
5. Fix any files with missing frontmatter fields

### Step S6: Report

Present a summary:

```
🔍 同步完成 — 全 vault
  - 当前设备: {从 S1 获取}
  - 扫描目录: <N>
  - 扫描文件: <N>
  - 修复 frontmatter: <N>
  - 设备标记更新: <N>
  - Skills/浏览器自动化/ 新编号范围: 01-<N>
  - Skills/搜索代理/ 新编号范围: 01-<N>
  - Skills/效率工具/ 新编号范围: 01-<N>
  - Skills/启动验证/ 新编号范围: 01-<N>
  - Skills/媒体创作/ 新编号范围: 01-<N>
  - Skills/知识管理/Obsidian生态/ 新编号范围: 01-<N>
  - Skills/知识管理/个人效能/ 新编号范围: 01-<N>
  - Skills-Packs/01-Superpowers/ 所有子目录: 01-<N>
  - Skills-Packs/02-Anthropic/ 所有子目录: 01-<N>
  - Skills-Packs/03-MattPocock/ 所有子目录: 01-<N>
  - Skills-Packs/04-GStack/ 所有子目录: 01-<N>
  - Skills-Packs/05-Awesome-Copilot/: 01-<N>
  - MCP/: 01-<N>
  - 插件/: 01-<N>
```

## Template Sync Workflow

**Routing:**
- `"模板变了"` / `"更新模板"` / `"同步模板"` / `"template changed"` → full run T1→T6
- `"更新所有文档"` / `"刷新所有文档"` / `"refresh all docs"` → skip T1/T3/T4, run T4a2 + T4b + T5, skip T6

This workflow normalizes frontmatter field order, field names, device tracking, body section structure, and refreshes live data (stars, dates, changelog).

### Step T1: Read the Template

1. Read `{VAULT_BASE}/00-工具功能介绍模板.md`
2. Parse the frontmatter: capture field names and their exact order
3. Parse the body: identify section headers (`## Skills简介`, `## 触发条件`, `## 前置依赖`, `## 主要解决的问题`, `## 常用命令/语法`, `## 主要使用场景`, `## 注意事项`, `## 更新功能`) and their order
4. Note any changes from the previous template state (e.g., field added/removed/renamed, section added/removed/renamed)

### Step T2: Scan All Vault Files

Walk ALL `.md` files under `{VAULT_BASE}` (excluding the template itself).

### Step T3: Normalize Frontmatter Per File

For each file's frontmatter:

| Check | Action |
|-------|--------|
| Field order doesn't match template | Reorder fields to match template order exactly |
| Field name doesn't match template | Rename to match template exactly |
| Field removed from template (e.g., `tags:`) | Remove the field from all files |
| Field added to template (e.g., `使用平台:`) | Add the field with default value |
| `使用设备:` has wrong format | Fix: YAML list (`  - Device`) or `使用设备: N/A` |
| Missing `使用设备:` | Add based on install detection |
| Boolean values not lowercase | Fix: `True` → `true`, `False` → `false`, `Yes` → `yes` |
| YAML parse errors | Fix frontmatter formatting |

**Device detection:** Follow [使用设备 判定规则](#使用设备-判定规则) for each file.

Update `使用设备:` based on detection result:
- Installed → `使用设备:\n  - Mac Mini`
- Not installed → `使用设备: N/A`

### Step T4: Normalize Body Section Structure

If the template has added, removed, or reordered body sections:

1. Map each file's existing sections to the template's section order
2. Remove sections that no longer exist in the template (e.g., `参考链接`)
3. Add new empty sections from the template (e.g., `常用命令/语法`)
4. Reorder sections to match template order

Do NOT overwrite or remove content within sections — only add/remove/reorder the section headers.

### Step T4a: 模板节内容 — 补空模式

**Scope:** ALL `.md` files under `辅助工具/` that have empty or missing template sections (触发条件, 前置依赖, 主要解决的问题, 主要使用场景, 注意事项, 更新功能, 常用命令/语法).

**Goal:** No file should have empty sections. Every template section must contain meaningful content derived from internet research.

**Execution:**

1. **Scan for gaps:** For each file, check which of the 8 template sections are missing or contain only `> ` / whitespace.

2. **Identify the tool/skill:** Extract `工具名` from frontmatter, or infer from filename and `Skills简介`.

3. **Internet research (do one of):**
   - If the tool has a `GitHub连接` → open the GitHub README, extract relevant section content
   - If the tool is from a known collection (Anthropic/MattPocock/Superpowers/AddyOsmani/GStack) → search web for the skill's documentation
   - If the tool is a CLI/package → search web for its official docs
   - Use `websearch` tool with query: `"{tool-name} AI agent skill documentation"` or `"{tool-name} CLI tool features"`

4. **Fill each section with real content:**
   - `触发条件` → When should an agent/user invoke this tool? What problem triggers its use?
   - `前置依赖` → What runtimes, packages, or prior setup are needed?
   - `主要解决的问题` → ❌/✅ table with 3+ pain points and how this tool solves them
   - `常用命令/语法` → Actual command examples, code blocks
   - `主要使用场景` → Bullet list with **bold** scene names + descriptions
   - `注意事项` → Caveats, known limitations, version-specific warnings
   - `更新功能` → "无（首次记录）" for new entries, or research changelog

5. **Content rules:**
   - Content must be in Chinese (except code blocks, URLs, proper nouns)
   - Do NOT copy placeholder text from the template
   - Base content on actual research, not speculation
   - If web research yields no results, derive content from the existing `Skills简介` section
   - After filling, verify the file reads naturally as a complete document

**Batching:** Process files in parallel by category (Skills/, Skills-Packs/*, 工具/, MCP/, 插件/). For large packs (GStack 45, AddyOsmani 24), split into sub-batches.

### Step T4a2: 模板节内容 — 全量刷新模式

**Triggers:** `"更新所有文档"` / `"refresh all docs"` — skips T1/T3/T4, runs T4a2 + T4b only.

**Scope:** ALL `.md` files under `辅助工具/`.

**Goal:** Every section in every file is re-checked against current source material. Existing content is kept unless new information is found.

**Execution:**

1. For each file, extract `工具名` and `GitHub连接`.

2. **Research current source:**
   - Has `GitHub连接` → fetch README, compare against current vault content section by section
   - From a known collection → search web for updated documentation
   - CLI/package → check official docs for changes

3. **Update sections where new info found:**
   - `触发条件` — new use cases or trigger scenarios
   - `主要解决的问题` — new pain points added, old ones obsolete
   - `常用命令/语法` — new flags, subcommands, or examples
   - `主要使用场景` — additional use cases
   - `注意事项` — new caveats or deprecations
   - Only write if there is new information — otherwise leave unchanged

4. **Append to `更新功能`:**
   - If any section was updated → add entry: `"YYYY-MM-DD: 更新 [section]"`.
   - If no changes → no new entry (T4b handles the `"无"` case).

**No per-file confirmation — batch and report.

### Step T4b: 数据刷新

For every `.md` file under `辅助工具/`:

1. **GitHub星标** — fetch 对应 repo 页面, 解析星标数后写回
2. **更新日期** — 设为当天 `YYYY-MM-DD`
3. **更新功能** — 查 repo release 日志, 与上次 `更新日期` 对比:
   - 有更新 → 写新条目
   - 无变化 → 写 `"无（数据已同步）"`

No per-file confirmation needed — batch and report.

### Step T5: Verify and Report

1. Re-read every modified file and verify the YAML parses correctly
2. Run a validation pass:
   - All frontmatter fields match template order
   - No stale fields (renamed fields, removed fields)
   - `使用设备:` values are correct (no `False` from YAML boolean parsing)
   - `必用:` values are lowercase (`true`/`false`)
3. Present a summary:

```
📋 模板同步完成
  - 总文件: <N>
  - 字段重排: <N>
   - 字段重命名: <N>
   - 使用设备更新: <N>
   - 布尔值修复: <N>
   - GitHub星标更新: <N>
   - 更新日期写入: <N>
   - 错误: 0
```

4. If any files couldn't be parsed correctly, report them as errors and do not modify them.

### Step T6: Update Template Hash

1. Run `md5 -q "{VAULT_BASE}/00-工具功能介绍模板.md"` to compute the new template hash
2. Update `template_hash` in this SKILL.md's frontmatter to the new hash
3. Update `template_checked` to today's date
4. Confirm to the user: "模板哈希已更新，后续将自动检测变更"

## Fix Workflow

Triggered by `"修复文档/修复格式/检查格式"` / `"fix docs"`. Scans vault for known format issues and fixes them. Does NOT renumber, refresh data, or sync templates.

### Step F1: Scan All Vault Files

Walk ALL `.md` files under `{VAULT_BASE}` (excluding the template itself).

### Step F2: Check and Fix Known Issues

| Check | Detection | Fix |
|-------|-----------|-----|
| `aliases` 含 `@` 前缀 | Parse frontmatter, aliases value starts with `@` | Remove `@` prefix, keep rest of text |

*(Add rows to this table as new format issues are identified.)*

For each file:
- Detect which checks trigger
- Apply fixes
- Track what was changed

### Step F3: Report

```
✅ 文档修复完成
  - 检查文件: <N>
  - 发现问题: <N>
  - 已修复: <N>
    - <filepath> → <fix description>
```

If no issues found: "✅ 文档格式检查通过，未发现问题"

## Quality Checks

- Read back first few lines to verify content
- Installation commands must be the actual commands used
- Section structure must match the template
- No placeholder text left in the document
- After renumbering, verify no files are missing or misnumbered

## Red Flags

Stop and re-evaluate if you catch yourself thinking:

| Thought | Reality |
|---------|---------|
| "这个工具我很熟，不用查资料了" | 必须查官方文档/README |
| "star 数大概记得，不用查" | 必须现查，从不用记忆 |
| "先安装了再说" | 必须先查信息 → 再安装 → 最后记录 |
| "这个不需要模板" | 必须使用 `00-工具功能介绍模板.md` |
| "记录到目录就行了，不用管编号" | 必须全局排序并重编号 |
| "它就是一个小工具，不用查 GitHub" | 每个工具都要查，无 GitHub 的标 N/A |
| "这跟已有的工具很像，直接跳过" | 必须检查确切匹配，不能猜 |
| "手动删了几个文件，编号我手动改一下就好" | 用 sync 工作流自动处理 |
| "这个工具就在这台电脑上用的，不用写设备名" | 必须写，sync 会自动检测补充 |
| "模板只改了一点点，不用同步" | 模板变了必须运行 Template Sync |
| "PowerShell 脚本改 YAML 没问题" | 必须用结构化 YAML 解析 |
| "移动文件到另一个目录，改个数字就行" | 同时涉及源和目标目录的编号更新，重命名可能有冲突 |

> 分类误放案例见 [Known Misclassifications](#known-misclassifications反面教材) 表。

## Edge Cases

| Case | Handling |
|------|----------|
| Template file not found | Stop with error: "模板文件不存在：{TEMPLATE}" |
| GitHub fetch fails | Set `GitHub星标: N/A`, do not block |
| No GitHub repository | Set `GitHub连接: ⚠️ Unknown`, `GitHub星标: N/A` |
| Tool already documented | Update existing file, do not duplicate |
| Category directory doesn't exist | Create it automatically |
| Star count format varies | Parse: `12K` → 12000, `1.5K` → 1500, `N/A` → 0 |
| Empty non-template files (e.g. OPENdesign.md) | Skip — no frontmatter, not a tool document |
| Multiple files share the same star count | Sort alphabetically by tool name |
| File rename fails during renumbering | Stop and report which file failed |
| No existing files in directory | Number new file as `01` |
| No `必用: true` tools found during deployment | Report "没有标记必用的工具" and stop |
| Install command is ambiguous | Ask user to clarify before proceeding |
| Tool is already installed | Skip, do not reinstall |
| Install command fails | Record the error, continue with next tool |
| User manually deleted files | Sync workflow detects and renumbers around them |
| Numbering has gaps | Sync workflow closes all gaps |
| Frontmatter fields out of order | Reorder to match template order |
| Stale frontmatter field found | Rename/remove to match template |
| File was renamed but not numbered | Sanitize name to match convention |
| Hostname not found in Device Configuration | Ask user to identify the current device |
| Tool install detection is ambiguous | Check multiple methods (`which`, `brew list`, etc.) |
| Device already in `使用设备` | Skip, do not duplicate |
| Tool not installed on current device | Set `使用设备: N/A` if no devices are listed |
| Template hash mismatch detected | Ask user whether to run Template Sync |
| Template hash not set in SKILL.md | Compute and set during first Template Sync run |
| User declines template sync | Update `template_hash` to current, skip syncing |
| Moving file between directories | **BOTH** source and target need renumbering. Source: remove and compress numbering. Target: insert file and renumber entire directory. NEVER just rename — you must rename ALL files in both directories if sorting changes. |
| File rename collision (rename A→3 when 3 exists) | Use an intermediate temp name: A→temp, B→A, C→B, temp→C |
| Superpowers core skills (核心技能) | Detectable via npm cache (`{npm-cache}/superpowers/skills/`). On Windows: `$env:USERPROFILE\.cache\opencode\packages\superpowers@git+https_\github.com\obra\superpowers.git\node_modules\superpowers\skills\`. On Mac: via npm cache. NOT found via `npx skills list -g`. |
| Skill is domain-specific (Obsidian/MCP/GStack/Codex) | Place in the correct domain directory per the S2 table, not a generic one. |
| Skill exists in both `Skills/` and `Skills-Packs/` | **Pack version wins.** Delete from `Skills/` (individual). Pack members take priority. Never keep duplicates. |
| `工具名` format mismatch with filename | 工具名 应使用英文首字母大写的自然名称（如 `Agent Browser`），文件名自动从中推导 Pascal-kebab |
| `GitHub连接` format | 必须使用 HTTPS 格式 `https://github.com/owner/repo`，不用 `git@` 或裸 `owner/repo` |
| `创建日期` / `更新日期` format | 固定 `YYYY-MM-DD`，不用 `YYYY/MM/DD` 或 `YYYY.MM.DD` |
| `使用平台` values | 取值限定：`全平台` / `macOS` / `Windows` / `Web`，不要自定义 |
| `npx skills add` 安装失败 | 检查网络/权限/npm 缓存，记录错误后继续，不阻塞工作流 |
| Cross-device sync conflict | 设备 A 修改文件后推送 → 设备 B 拉取后需重新运行 Sync 工作流校验 |

## Anti-Patterns

**安装前后：**
- Don't write the doc before confirming installation succeeded
- Don't install tools the user didn't mark as `必用`
- Don't reinstall already-present tools without asking
- Don't guess about tool existence — read frontmatter to check

**目录与编号：**
- Don't skip creating category directories if they don't exist
- Don't move files between directories without handling both source and target numbering — use intermediate temp names to resolve rename collisions
- Don't create 3-level directories for 1-2 files

**模板与字段：**
- Don't skip frontmatter validation during sync
- Don't assume field order doesn't matter — it must match the template exactly
- Don't keep stale fields when the template removes or renames them
- Don't leave `使用设备: False` (YAML boolean corruption) — fix to `no` or proper list format
- Don't leave `GitHub连接: 无` — use `⚠️ Unknown` or the actual URL

**YAML：**
- Don't use PowerShell/batch string manipulation (regex, -replace, string concatenation) on YAML frontmatter — use proper YAML parsing or read/write the whole block

**分类：**
- Don't classify by name or domain alone — classify by execution context: Agent 外部 → 工具/, Agent 内部 + SKILL.md → Skills/, Agent 内部 + 运行时注入 → 插件/
- Don't put CLI tools / Python frameworks / npm packages in Skills/
- Don't put Obsidian plugins in Skills/ or 插件/ — 运行在 Agent 外部就是 工具/
- Don't confuse 插件/ with 工具/ — 插件/ 只放注入 Agent 运行时的软件

**去重：**
- Don't keep duplicate skills across `Skills/` and `Skills-Packs/` — pack version wins, delete from Skills/
