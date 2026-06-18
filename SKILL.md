---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when the vault's skill documentation needs organizing, renaming, or standardizing. Also use when the vault documentation template changes and all files need syncing to match.
template_hash: 46df8d3e430e027259091040fbf9bd35
template_checked: 2026-06-18
---

# Obsidian Skill Manager

## Overview

Four workflows:

**Recording:** When installing any tool, automatically gather information, execute installation, determine category, assign a number by popularity (GitHub stars), and record everything into the user's Obsidian vault following their template format. If the tool is already documented, update it instead of duplicating.

**Deployment:** When setting up a new device, scan the vault for commonly-used tools (`必用: true`), infer the install commands from each document, execute them, and deploy corresponding opencode skills.

**Sync:** When the user says "执行" or "sync", scan the vault for deleted or renamed files, detect gaps in numbering, and globally re-sort everything to maintain consistency.

**Template Sync:** When the vault documentation template (`00-工具功能介绍模板.md`) changes, sync all vault files to match — normalize frontmatter field order, field names, section structure, and device tracking values.

## Triggering

This skill activates in three modes:

**Recording mode** — when the user acquires new software:
- "安装 X" / "下载 X" / "添加 X"
- "设置 X" / "配置 X"
- "install X" / "setup X" / "add X"
- Any request involving acquiring new software

**Deployment mode** — when the user sets up a new device:
- "部署到这台电脑" / "安装常用" / "同步技能"
- "deploy my skills" / "setup this machine"

**Sync mode** — when the user wants to clean up and re-sort:
- "执行" / "同步" / "清理"
- "sync" / "clean up" / "reindex"

**Template Sync mode** — when the vault template changes and needs propagation:
- "模板变了" / "模板更新" / "同步模板"
- "template changed" / "sync template" / "更新模板"
- "按这个模板来更新" / "按模板更新"
- Any instruction to match all docs to a specific template format

## Vault Configuration

**macOS (Mac Mini):**
```
VAULT_BASE = /Users/x1rz47/Library/CloudStorage/SynologyDrive-x1Rz47/5.个人资料/1.知识库/个人知识库/04.AI相关-🤖
TEMPLATE   = {VAULT_BASE}/00-工具功能介绍模板.md
```

**Windows (WPC):**
```
VAULT_BASE = D:\SynologyDrive\5.个人资料\1.知识库\个人知识库\04.AI相关-🤖
TEMPLATE   = {VAULT_BASE}\00-工具功能介绍模板.md
```

## Category Directories

See [Sync S2 table](#step-s2-scan-all-vault-directories) for the canonical directory list and numbering rules.

## Device Configuration

| Hostname | Device Name |
|----------|-------------|
| `x1Rz47-A1213` | Mac Mini |
| `WPC-x1Rz47` | WPC |

To determine the current device, check `hostname` and map it using this table. If the hostname is not yet mapped, ask the user to name the device.

## 使用设备 判定规则

`使用设备` 字段记录该工具/技能**在当前设备上是否实际安装和可用**，不是"相关应用已安装"或"依赖已存在"。

| 工具类型 | 判定方式 | 示例 |
|---------|---------|------|
| agent skill | `npx skills list -g` 可见，或在 `~/.config/opencode/skills/` (Mac) / `~\.agents\skills\` (Windows) 目录下 | `video-use` → `- Mac Mini` / `- WPC` |
| MCP server | `opencode.jsonc` 的 `mcpServers` 中已配置 | `markitdown-mcp` → `- Mac Mini` |
| CLI 工具 | `which <tool>` (Mac) / `where.exe <tool>` (Windows) 能找到 | `ffmpeg` → `- Mac Mini` / `- WPC` |
| brew 包 | `brew list <pkg>` 成功 (仅 Mac) | `gh` → `- Mac Mini` |
| npm 全局包 | `npm list -g <pkg>` 可见 | `bun` → `- Mac Mini` / `- WPC` |
| pip 包 | `pip3 list \| grep <pkg>` (Mac) / `pip list \| findstr <pkg>` (Windows) 有结果 | `openai-whisper` → `- Mac Mini` |
| 工作流/流程文档 / Skills-Packs | 不可安装，永远不写设备名 | GStack、Superpowers、Anthropic 等 → `N/A` |

**常见的错误模式（禁止）：**
- Obsidian App 已安装 ≠ `kepano/obsidian-skills` 仓库的 agent skill 已安装
- 电脑上有 ffmpeg ≠ `manim` 这个 Python 包已安装
- 依赖存在 ≠ 工具本身存在

**总结：只查工具本身是否安装，不查上下游依赖，不查相关生态工具。**

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

Before ANY workflow (Recording, Deployment, Sync, Template Sync), check if the vault template has changed:

### Step 0.1: Compute Current Template Hash

Run `md5 -q "{VAULT_BASE}/00-工具功能介绍模板.md"` to get the current MD5 hash of the template file.

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

## Recording Workflow

### Step 1: Identify the Tool

Determine:
- **Name**: What is it called?
- **Type**: skill / 插件 / MCP / npm package / config / other
- **Source**: GitHub / npm / brew / pip / direct download
- **Category**: Map source to target directory using the [Sync S2 table](#step-s2-scan-all-vault-directories).

### Step 2: Gather Information

Collect:
- Description from official docs/README
- GitHub URL and star count (use web search)
- Installation command
- Core features
- Dependencies
- Any warnings or notes

If GitHub fetch fails (network error, no GitHub repo), set `GitHub星标: N/A`. Do not block the workflow.

### Step 3: Execute Installation

Run the installation command. Wait for it to complete. Verify success.

After installation, determine the current device name from the Device Configuration table. Add the device name to `使用设备` in the frontmatter: `使用设备:\n  - Mac Mini`. If the tool doesn't support direct binary detection (like process workflows), set `使用设备: N/A`.

### Step 4: Check for Existing Document

Before creating a new file:
1. Read all files in the target category directory
2. Parse frontmatter of each file for `工具名` and `aliases`
3. If a match is found → this is an **UPDATE**:
   - Update `更新日期` to today (every modification)
   - Do NOT modify `创建日期` — it is set once on creation and never changed
   - Add a new entry to `更新功能`: e.g. "更新于 2026-06-06: 更新了核心功能描述"
   - Merge new information into existing sections
   - Do NOT change the file's number
   - Skip Steps 5-6, go directly to Step 7
4. If no match → this is a **NEW** entry, proceed to Step 5

### Step 5: Global Sort and Renumber (NEW entries only)

1. Read the `GitHub星标` frontmatter field from ALL existing files in the target directory
2. Parse star counts:
   - `12K` → 12000
   - `1.5K` → 1500
   - `N/A` → 0 (sorts to end)
3. Sort all entries (new + existing) by:
   - Primary: star count descending
   - Secondary: tool name alphabetically (for equal star counts)
4. Assign new numbers: `01`, `02`, `03`...
5. Determine the filename from `工具名` in frontmatter:
   - Convert to Pascal-kebab-case: `Find Skills` → `Find-Skills`, `Create Agents` → `Create-Agents`
   - Result: `{NN}-{Pascal-Kebab-Name}.md`
6. Rename files on disk to match: `{NN}-{Pascal-Kebab-Name}.md`

Edge case — tools with `N/A` stars: always sort to the end, ordered alphabetically among themselves.

### Step 6: Generate Obsidian Document

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

**Device detection rules:**
- If the tool is installed on the current device → add `  - <DeviceName>` under `使用设备:`
- If the tool is NOT installed → set `使用设备: N/A`
- Determine install status via: `which`, `brew list`, `npm list -g`, `pip list`, `npx skills list -g`

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

### Step 7: Save and Confirm

Write to `{VAULT_BASE}/{category}/{filename}`.
Confirm to the user that the tool is installed and documented.

## Deployment Workflow (New Device Setup)

This workflow runs independently from the recording workflow above. Use it when setting up a new machine.

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
| `辅助工具/Skills/开发辅助/架构与Agent框架/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/搜索代理/跨平台搜索/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/搜索代理/代码探索/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/浏览器自动化/通用浏览自动化/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/浏览器自动化/测试框架/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/媒体创作/视频制作/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/媒体创作/内容创作/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/知识管理/Obsidian生态/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/知识管理/文档协作/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/知识管理/个人效能/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/效率工具/提示沟通/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/效率工具/Agent编排/` | By GitHub stars (desc) | Full template |
| `辅助工具/Skills/启动验证/` | By GitHub stars (desc) | Full template |
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

Used by Recording Step 6 and Sync S3 — extend as new tools are installed.
Kept in global copy at `~/.config/opencode/skills/obsidian-skill-manager/SKILL.md` so all sessions benefit.

| 工具名 (`工具名`) | GitHub Repo |
|---|---|---|
| `Find Skills` / `find-skills` | `https://github.com/vercel-labs/skills` |
| `Acquire Codebase Knowledge` / `acquire-codebase-knowledge` | `https://github.com/github/awesome-copilot` |
| `Documentation Writer` / `documentation-writer` | `https://github.com/github/awesome-copilot` |
| `Create Agents` / `create-agents` | `https://github.com/github/awesome-copilot` |
| `Obsidian Skill Manager` / `obsidian-skill-manager` | `https://github.com/x1Rz47/Obsidian-Skill-Manager` |
| `Data Visualization` / `data-visualization` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Memory Management` / `memory-management` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Task Management` / `task-management` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Technical Documentation` / `technical-documentation` | `https://github.com/anthropics/knowledge-work-plugins` |
| `Repomix Explorer` / `repomix-explorer` | `https://github.com/yamadashy/repomix` |
| `Documentation And Adrs` / `documentation-and-adrs` | `https://github.com/addyosmani/agent-skills` |
| (All `mattpocock/skills` skills — 工程开发 12) | `https://github.com/mattpocock/skills` |
| (All `mattpocock/skills` skills — 工作效率 5) | `https://github.com/mattpocock/skills` |
| (All `mattpocock/skills` skills — 其他 4) | `https://github.com/mattpocock/skills` |
| `GBrain` / `gbrain` | `https://github.com/garrytan/gbrain` |
| `Video Use` / `video-use` | `https://github.com/instafluff/video-use` |
| `Manim Video` / `manim-video` | `https://github.com/anthropics/manim-video` |
| `MarkItDown` / `markitdown` | `https://github.com/microsoft/markitdown` |
| `Supermemory` / `supermemory` | `https://github.com/anthropics/supermemory` |
| `Brainstorming` (Superpowers) | `https://github.com/obra/superpowers` |
| `Goal Prompt Builder` / `goal-prompt-builder` | `https://github.com/win4r/goal-prompt-builder` |
| `Agent Browser` / `agent-browser` | `https://github.com/vercel-labs/agent-browser` |
| (All `anthropics/skills` skills) | `https://github.com/anthropics/skills` |
| (Add rows as new tools are installed)

### Step S4: Device Tracking

For each skill, infer its install command and check if the tool is installed on the current device:
- `which <command>` for CLI tools
- `brew list` for Homebrew packages
- `npm list -g` for global npm packages
- `pip list` for Python packages
- `npx skills list -g` for opencode skills
- MCP config in `opencode.jsonc` for MCP servers

Update `使用设备:` per file:

| Install Status | Action |
|---------------|--------|
| Tool IS installed | Add `  - <DeviceName>` under `使用设备:` |
| Tool NOT installed and `使用设备:` is empty or has no entries | Set `使用设备: N/A` |
| Tool NOT installed but `使用设备:` has entries from other devices | Leave existing entries unchanged |
| Workflow/process doc / Skills-Packs | Set `使用设备: N/A` (not installable software)

### Step S5: Global Re-Sort

For all directories sorted by GitHub stars, renumber files:

1. Sort by `GitHub星标` descending (N/A → end)
2. For equal stars, sort alphabetically by `工具名`
3. Renumber from `01` upwards
4. Rename all files to `{NN}-{Pascal-Kebab-Name}.md`
5. Fix any files with missing frontmatter fields

### Step S6: Report

Present a summary:

```
🔍 同步完成 — 全 vault
  - 当前设备: Mac Mini
  - 扫描目录: <N>
  - 扫描文件: <N>
  - 修复 frontmatter: <N>
  - 设备标记更新: <N>
  - Skills/开发辅助/架构与Agent框架/ 新编号范围: 01-<N>
  - Skills/搜索代理/跨平台搜索/ 新编号范围: 01-<N>
  - Skills/搜索代理/代码探索/ 新编号范围: 01-<N>
  - Skills/浏览器自动化/通用浏览自动化/ 新编号范围: 01-<N>
  - Skills/浏览器自动化/测试框架/ 新编号范围: 01-<N>
  - Skills/媒体创作/视频制作/ 新编号范围: 01-<N>
  - Skills/媒体创作/内容创作/ 新编号范围: 01-<N>
  - Skills/知识管理/Obsidian生态/ 新编号范围: 01-<N>
  - Skills/知识管理/文档协作/ 新编号范围: 01-<N>
  - Skills/知识管理/个人效能/ 新编号范围: 01-<N>
  - Skills/效率工具/提示沟通/ 新编号范围: 01-<N>
  - Skills/效率工具/Agent编排/ 新编号范围: 01-<N>
  - Skills/启动验证/ 新编号范围: 01-<N>
  - Skills-Packs/01-Superpowers/ 所有子目录: 01-<N>
  - Skills-Packs/02-Anthropic/ 所有子目录: 01-<N>
  - Skills-Packs/03-MattPocock/ 所有子目录: 01-<N>
  - Skills-Packs/04-GStack/ 所有子目录: 01-<N>
  - Skills-Packs/05-Awesome-Copilot/: 01-<N>
  - MCP/: 01-<N>
  - 插件/: 01-<N>
```

## Template Sync Workflow

This workflow runs when the user updates `{TEMPLATE}` and asks for all vault files to be synchronized to match. It normalizes frontmatter field order, field names, device tracking, and body section structure.

### Step T1: Read the Template

1. Read `{VAULT_BASE}/00-工具功能介绍模板.md`
2. Parse the frontmatter: capture field names and their exact order
3. Parse the body: identify section headers (`## Skills简介`, `## 触发条件`, `## 前置依赖`, `## 主要解决的问题`, `## 常用命令/语法`, `## 主要使用场景`, `## 注意事项`, `## 更新功能`) and their order
4. Note any changes from the previous template state (e.g., field added/removed/renamed, section added/removed/renamed)

### Step T2: Scan All Vault Files

Walk ALL `.md` files under `{VAULT_BASE}` (excluding the template itself and empty files like `OPENdesign.md`).

### Step T3: Normalize Frontmatter Per File

For each file's frontmatter:

| Check | Action |
|-------|--------|
| Field order doesn't match template | Reorder fields to match template order exactly |
| Field name changed (e.g., `Github连接` → `GitHub连接`, `Github星标` → `GitHub星标`) | Rename to match template |
| Field removed from template (e.g., `tags:`) | Remove the field from all files |
| Field added to template (e.g., `使用平台:`) | Add the field with default value |
| `使用设备:` has wrong format | Fix: YAML list (`  - Device`) or `使用设备: N/A` |
| Missing `使用设备:` | Add based on install detection |
| Boolean values not lowercase | Fix: `True` → `true`, `False` → `false`, `Yes` → `yes` |
| YAML parse errors | Fix frontmatter formatting |

**Device detection for `使用设备:`:**
For each file, detect if the documented tool is actually installed:
- `which <tool>` for CLI tools
- `brew list <tool>` for Homebrew packages
- `npm list -g <package>` for global npm packages
- `pip3 list` | grep for Python packages
- `npx skills list -g` for global skills
- MCP config in `opencode.jsonc` for MCP servers

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

### Step T4b: 辅助工具/ 全库模板化 + 汉化

**Scope:** ALL `.md` files under `辅助工具/` (Skills, Skills-Packs, MCP, 插件, 工具). Does NOT apply to files outside `辅助工具/`.

**Goal:** Every file must use only the 8 template sections (`Skills简介 → 触发条件 → 前置依赖 → 主要解决的问题 → 常用命令/语法 → 主要使用场景 → 注意事项 → 更新功能`). All English section headers and content must be translated to Chinese. Only code blocks, URLs, and technical proper nouns (SDK, API, etc.) stay untranslated.

**Two-pass execution:**

**Pass 1 — Content restructuring:** Map all non-template sections into template sections using keyword-based heuristics:
- `开始之前` / `Before You Start` / `Precondition` / `安装` → `触发条件` + `前置依赖`
- `子命令` / `Output` / `语法` / `Usage` / `Example` / `阶段` / `流程` / `Steps` → `常用命令/语法`
- `Overview` / `目的` / `Introduction` / `What to build` → `主要解决的问题`
- `When` / `何时` / `Use Case` → `主要使用场景`
- `Common Pitfall` / `Failure mode` / `反模式` → `注意事项`
- `Changelog` / `版本` → `更新功能`
- Unmappable sections (design principles, brand guidelines, etc.): promote to `### Subsection` within `Skills简介`

**Pass 2 — Content translation:** Translate all remaining English prose to Chinese using Google Translate API via `deep-translator`. Handle files over 5000 chars by splitting into chunks. Protect code blocks, inline code, URLs, and HTML comments from translation.

**SKills-Packs imported skills (Anthropic/MattPocock/Superpowers/GStack/Awesome-Copilot):**
- Original sections are restructured into template sections via heuristic mapping
- Content is translated to Chinese (prose only, code and terms preserved)
- Cannot-mapped content goes into `Skills简介` as `### 子节`

**Reference:** The section-mapping keyword rules and translation logic are maintained in the execution scripts. When encountering a new section type, add its keyword mapping to the script and re-run.

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
  - 错误: 0
```

4. If any files couldn't be parsed correctly, report them as errors and do not modify them.

### Step T6: Update Template Hash

1. Run `md5 -q "{VAULT_BASE}/00-工具功能介绍模板.md"` to compute the new template hash
2. Update `template_hash` in this SKILL.md's frontmatter to the new hash
3. Update `template_checked` to today's date
4. Confirm to the user: "模板哈希已更新，后续将自动检测变更"

## Quality Checks

- Verify the file was written correctly (read back first few lines)
- GitHub star count should be accurate (fetched, not guessed)
- Installation commands must be the actual commands used
- Sections should follow template structure
- No placeholder text left in the document
- After renumbering, verify no file is missing or has a wrong number

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
| "手动删了几个文件，编号我手动改一下就好" | 用 sync 工作流自动处理，不要手动改编号 |
| "这个工具就在这台电脑上用的，不用写设备名" | 必须写！sync 会自动检测补充 |
| "模板只改了一点点，不用同步" | 模板变了必须运行 Template Sync，即使改动很小 — 字段会被慢慢遗忘 |
| "PowerShell 脚本改 YAML 没问题" | 必须用结构化 YAML 解析，字符串替换可能产生空文件 |
| "这个 Obsidian 技能放哪都行" | Obsidian 生态类 skill 必须放到 知识管理/Obsidian生态/ |
| "移动文件到另一个目录，改个数字就行" | 同时涉及源目录和目标目录的编号更新，重命名可能有冲突 |

## Edge Cases

| Case | Handling |
|------|----------|
| Template file not found | Stop with error: "模板文件不存在：{TEMPLATE}" |
| GitHub fetch fails | Set `GitHub星标: N/A`, do not block |
| No GitHub repository | Set `GitHub连接: ⚠️ Unknown`, `GitHub星标: N/A` |
| Tool already documented | Update existing file, do not duplicate |
| Category directory doesn't exist | Create it automatically |
| Star count format varies | Parse: `12K` → 12000, `1.5K` → 1500, `N/A` → 0 |
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

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "I know this tool well enough" | What you know ≠ what belongs in documentation. Fetch fresh info. |
| "The stars are roughly correct" | Roughly ≈ wrong. Fetch exact count. |
| "Renumbering is tedious, I'll skip it" | Without sorting, the numbering system breaks. Never skip. |
| "This is just a small utility" | Small tools need documentation too. Follow the full workflow. |
| "The template is overkill for this" | The template exists for a reason. Use it. Every time. |

## Anti-Patterns

- Don't skip info gathering ("I know this tool already")
- Don't write the doc before confirming installation succeeded
- Don't use star counts from memory — always fetch fresh
- Don't skip the template — user has a specific format they want
- Don't skip creating category directories if they don't exist
- Don't skip global renumbering — it's required on every new addition
- Don't guess about tool existence — read frontmatter to check
- Don't install tools the user didn't mark as `必用` — only deploy what's explicitly flagged
- Don't reinstall already-present tools without asking
- Don't manually edit file numbers — use sync workflow instead
- Don't skip frontmatter validation during sync — catch missing fields
- Don't assume field order doesn't matter — it must match the template exactly
- Don't keep stale fields when the template removes or renames them
- Don't leave `使用设备: False` (YAML boolean corruption) — fix to `no` or proper list format
- Don't treat template syncing as optional — when the template changes, all files must follow
- Don't use PowerShell string manipulation (regex, -replace, string concatenation) to edit YAML frontmatter — YAML is structured data, use proper YAML parsing or read/write the whole frontmatter block carefully
- Don't keep duplicate skills across `Skills/` and `Skills-Packs/` — if a pack covers a skill, the Skills/ copy must be deleted
- Don't move files between directories without handling both source and target numbering — both directories need renumbering, and file rename conflicts (01→03 when 03 exists) require intermediate temp names
- Don't assume Obsidian skills belong in 开发辅助/ — check if the skill is knowledge-management-specific and put it in `知识管理/` instead
- Don't use batch string replacement (`-replace`) on YAML frontmatter — the result may silently produce empty files
