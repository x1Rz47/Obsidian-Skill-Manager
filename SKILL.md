---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when the vault's skill documentation needs organizing, renaming, standardizing, fixing, or format-checking. Also use when the vault documentation template changes and all files need syncing to match. Also use when the user says fix docs, fix format, 修复文档, 修复格式, or 检查格式.
metadata:
  template_hash: b033a64a9115d1aecfc5d4e49dbeba1c
  template_checked: 2026-06-20
  # WARNING: All section lists must be read from TEMPLATE.md, never hardcoded.
---

# Obsidian Skill Manager

## Triggering

This skill activates in eight modes:

| Mode | Trigger phrases |
|------|----------------|
| **Install** | "安装/下载 [工具]"、"install/setup/add [tool]" |
| **Document** | "记录 [工具]"、"给 [工具] 写个文档"、"doc [tool]" |
| **Combined** | "安装并记录 [工具]"、"install and doc [tool]" |
| **Deployment** | "部署/安装必用/安装常用/同步技能"、"deploy/setup this machine" |
| **Fix** | "修复文档/修复所有文档/修复格式/检查格式"、"fix docs/fix format" |
| **Sync** | "执行/同步/清理"、"sync/clean up/reindex" |
| **Template Sync** | "模板变了/更新模板/同步模板/更新所有文档/刷新所有文档"、"template changed/sync template/refresh all docs" |
| **Standardize** | "标准化所有文档/标准化文档/全面标准化"、"standardize all docs/full standardize" |

## Vault Configuration

`{TEMPLATE}` = `{SKILL_DIR}/TEMPLATE.md`. Hostname → config:

| Hostname | Device | VAULT_BASE | SKILL_DIR |
|----------|--------|------------|-----------|
| `x1Rz47-A1213` | Mac Mini | `/Users/x1rz47/Library/CloudStorage/SynologyDrive-x1Rz47/5.个人资料/1.知识库/个人知识库/04.AI相关-🤖` | `/Users/x1rz47/.agents/skills/obsidian-skill-manager` |
| `WPC-x1Rz47` | WPC | `D:\SynologyDrive\5.个人资料\1.知识库\个人知识库\04.AI相关-🤖` | `%USERPROFILE%\.agents\skills\obsidian-skill-manager` |
| _Other_ | — | Ask user to identify device | — |


## Classification Guide

按 **执行上下文** 分类：工具运行在 Agent **外部**（独立可执行）还是 **内部**（注入 Agent 运行时）？

| 类型 | 运行位置 | 识别方式 | 例子 |
|------|---------|---------|------|
| **MCP Server** | Agent 内部（协议） | 描述含 "MCP server" / "Model Context Protocol"；包名含 `-mcp` | MarkItDown-MCP, CodeGraph, GBrain |
| **Agent Skill** | Agent 内部（指令集） | 描述含 "skill"；仓库有 SKILL.md + 触发条件；安装：npx skills add | Playwright-skill, BrowserAct-skill, Find-Skills, Agent-Reach |
| **Skill Pack** | Agent 内部（指令集） | 多 skill 仓库；安装：npx skills add owner/repo | Superpowers, Anthropic, MattPocock, GStack |
| **插件** | Agent 内部（运行时注入） | 描述含 "plugin" / "inject into agent"；安装后修改 Agent 能力，不论平台 | supermemory, morph, type-inject, vibeguard |
| **工具** | Agent **外部** | 以上都不符合的可安装软件，不论具体形态 | yt-dlp, repomix, deepagents, agent-browser, Defuddle |

> **工具/ 是兜底分类。** 只要不是 MCP server、不是 agent skill、也不是注入 Agent 运行时的插件，全部归入 工具/。 Obsidian 插件、VS Code 扩展、OpenCode 插件中不注入运行时的部分，都是 工具/。
>
> 安装后与之前判断冲突 → 标记 `⚠️ 分类存疑，需人工确认`，不自动纠正。


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

**Independent numbering per directory (including 3rd-level subdirectories):** See [Sync S2 table](#step-s2-scan-all-vault-directories) for the canonical directory list and numbering rules. When moving or renaming files, always derive the natural name from the filename (strip `NN-` prefix and convert Pascal-kebab-case to natural name).

### Subdirectory Rule

当一个目录下同一类型的文档超过 **3 个** 时，应创建子分类文件夹：
- 子分类名用中文，不加编号（如 `语音合成/`、`浏览器自动化/`）
- 将对应文件移入子目录，**独立编号**（01-N，按 GitHub stars 降序）
- 文件 aliases 中文名同步改为新的子分类名
- 在 Sync S2 表中添加新子目录的行

### Aliases 规范

每个文件的 `aliases` 至少包含 **3 个条目**，遵循以下规则：

| # | 条目 | 规则 | 示例 |
|---|------|------|------|
| 1 | 英文名 | Pascal Case 无连词符，只写一个 | `BrowserAct` |
| 2 | 中文名 | 当前分类名，只写一个（来自目录结构） | `浏览器自动化` |
| 3+ | 核心技术关键词 | 至少 1 个，从文档简介/核心功能提取，可有多个 | `浏览器控制`、`Web自动化` |

```yaml
aliases:
  - BrowserAct           # 英文名（Pascal Case 无连词符）
  - 浏览器自动化          # 中文名（当前分类名）
  - 浏览器控制            # 核心技术关键词（至少 1 个）
  - Web自动化            # 核心技术关键词（可选）
```

## Common Pre-Check (Step 0: Template Hash Validation)

Before ANY workflow (Install, Document, Combined, Deployment, Sync, Template Sync), check if the vault template has changed:

### Step 0.1: Compute Current Template Hash

Run the appropriate command for the current OS to get the MD5 hash of `{TEMPLATE}`:
- **Mac:** `md5 -q "{TEMPLATE}"`
- **Windows:** `certutil -hashfile "{TEMPLATE}" MD5 | findstr /v "MD5"`

### Step 0.2: Compare with Stored Hash

Read `metadata.template_hash` from this SKILL.md's frontmatter:
- If hashes **match** → template unchanged, proceed to the requested workflow
- If hashes **differ** → template has been modified since last sync:
  1. Report the hash difference to the user
  2. Ask: "模板已更新，是否同步所有文档到新模板格式？"
  3. **User confirms** → abort current workflow, switch to **Template Sync Workflow** (Step T1-T5). After Template Sync completes, `metadata.template_hash` is automatically updated.
  4. **User declines** → update `metadata.template_hash` in SKILL.md frontmatter to the current hash without syncing. Continue with the requested workflow.

### Step 0.3: Update Timestamp

If `metadata.template_checked` is more than 7 days old, update it to today.

## Frontmatter Normalization Rules

Shared by Sync S3 and Template Sync T3. Apply these checks to every `.md` file before other workflow-specific logic.

| Check | Fix |
|-------|-----|
| Wrong field order | Reorder to match `{TEMPLATE}` field order exactly |
| `使用平台` value invalid | Must list specific platforms (OpenCode / Codex / Claude Code / Gemini), separated by ` / `. Never use `全平台` or `NO`. Example: `Claude Code / Codex / OpenCode` |
| `使用设备:` wrong format | Fix to YAML list (`  - Device`) or `使用设备: N/A` |
| Missing `使用设备:` | Add based on install detection |
| Boolean values not lowercase | Fix: `True` → `true`, `False` → `false`, `Yes` → `yes` |

## Body Section Conventions

文档 body 严格按 `{TEMPLATE}` 的 `##` 节结构和格式生成。各节的写法和示例见模板本身，不再重复。

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

If GitHub fetch fails (network error, no GitHub repo), set `GitHub Star: N/A`. Do not block the workflow.

### Step I3: Check for Existing Document

Before installing, scan the target directory in vault:
1. Read all files in the target category directory
2. Parse frontmatter of each file for `aliases` — the tool name is derived from the filename (strip `NN-` prefix, convert Pascal-kebab to natural name) or from the first `aliases` entry
3. If a match is found → tell the user: "该工具已记录过文档，不再重复记录"
4. If no match → proceed (Document workflow will handle it if needed)

Continue to install regardless of the result.

### Step I4: Execute Installation

Run the installation command. Wait for it to complete. Verify success.

After installation, note the current device name from Vault Configuration table. Device detection follows the [使用设备 判定规则](#使用设备-判定规则) table.

---

## Document Workflow（记录，不安装）

### Step W1: Check for Existing Document

1. Read all files in the target category directory
2. Parse frontmatter of each file for `aliases` — the tool name is derived from the filename (strip `NN-` prefix, convert Pascal-kebab to natural name) or from the first `aliases` entry
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
- 使用平台 — 从 GitHub README / 官网文档判断支持哪些 AI 编程平台（OpenCode / Codex / Claude Code / Gemini），多个用 / 分隔
- Any warnings or notes

### Step W3: Global Sort and Renumber (NEW entries only)

Follow [Sync Step S5](#step-s5-global-re-sort) for the target directory only.

### Step W4: Generate Obsidian Document

Read `{TEMPLATE}` for field order, section structure, and writing rules. Apply per-field overrides below:

**`GitHub 链接` must always be populated:**
- When installing via `npx skills add owner/repo@skill` → derive from `owner/repo` → `https://github.com/owner/repo`
- When installing via `npm install owner/repo` → derive from `owner/repo`
- When the install URL is known from the user or the skill source → write it directly
- NEVER leave `GitHub 链接` as `无` or empty — if truly unknown, set to `⚠️ Unknown` (not `无`)

**Device detection:** Follow the [使用设备 判定规则](#使用设备-判定规则) table to determine install status per device.

Write to `{VAULT_BASE}/{category}/{filename}`.
Confirm to the user that the tool is documented.

---

## Combined Workflow（安装并记录）

1. Run [Install Workflow](#install-workflow安装不动-vault) Steps I1-I4
2. After installation, if no existing document was found in Step I3, run [Document Workflow](#document-workflow记录不安装) Steps W2-W4 (skip W1, info was already gathered in I2)

## Deployment Workflow（部署必用工具）

Scan the vault for `必用: true` tools and install them on the current device.

### Step D1: Scan for Favorites

1. Read all .md files under `{VAULT_BASE}/辅助工具/` (all subdirectories — Skills/, Skills-Packs/, MCP/, 工具/, 插件/)
2. Parse frontmatter of each file, filter for `必用: true`
3. If none found, report "没有标记必用的工具" and stop

### Step D2: Install Each Favorite

For each file with `必用: true`:

1. Read the document body, focusing on the **用法** and **核心功能** sections
2. Infer the installation command(s) from the content
3. Determine what to install:
   - **System tool** (brew/pip/npm) → run the install command directly
   - **OpenCode skill** → create `~/.config/opencode/skills/{tool-name}/SKILL.md`
4. Check if already installed — skip if present
5. Execute the install command. Verify success.
6. Record success or failure

### Step D3: Report Results

Present a summary table of each tool and its status.

## Sync Workflow (Clean and Re-Sort)

This workflow runs independently. Use it when you've manually added, deleted, or renamed files in the vault, and need the numbering restored to a consistent state across all directories.

### Step S1: Determine Current Device

1. Run `hostname -s` (macOS) or `hostname` (Windows) to get the current machine's hostname
2. Look up the device name in the Vault Configuration table
3. If the hostname is not mapped, ask the user to identify the device

### Step S2: Scan All Vault Directories

Walk ALL `.md` files under `{VAULT_BASE}` grouped by directory:

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
| `辅助工具/Skills-Packs/06-AddyOsmani/{category}/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/Skills-Packs/07-PM-Skills/{category}/` | Manual (01-N, ordered at creation) | Full template |
| `辅助工具/MCP/` | By GitHub stars (desc) | Full template |
| `辅助工具/工具/` | By GitHub stars (desc) | Full template |
| `辅助工具/工具/语音合成/` | By GitHub stars (desc) | Full template |
| `辅助工具/插件/` | By GitHub stars (desc) | Full template |

For each file, parse its frontmatter and derive the tool name from the filename (strip `NN-` prefix, convert Pascal-kebab to natural name) or from the first `aliases` entry. Build a manifest: tool name, `GitHub Star`, `使用设备`, `必用`, and install commands.

### Step S3: Detect and Fix Issues Per File

Apply [Frontmatter Normalization Rules](#frontmatter-normalization-rules) to every file, plus Sync-specific checks:

- **Missing `必用:`** → Add `必用: false`
- **Wrong field name (`常用`)** → Rename to `必用`
- **`GitHub 链接` missing or `无`** → Auto-fill via web research; if still not found, set to `⚠️ Unknown`
- **`GitHub 链接` is `⚠️ Unknown`** → Leave as-is (flagged for review, don't auto-fix without confirming)
- **Naming mismatches** → Rename to `{NN}-{Pascal-Kebab-Name}.md`


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

1. Read `GitHub Star` from each file; parse counts: `12K` → 12000, `1.5K` → 1500, `N/A` → 0
2. Sort by star count descending (N/A → end); equal stars → alphabetically by filename-derived name (strip `NN-` prefix, convert Pascal-kebab to natural name)
3. Assign new numbers `01`, `02`, `03`...
4. Rename files to `{NN}-{Pascal-Kebab-Name}.md`
5. Fix any files with missing frontmatter fields

### Step S6: Report

Present a summary of scanned directories, files, fixes, and new numbering ranges per directory.

## Template Sync Workflow

**Routing:**
- `"模板变了"` / `"更新模板"` / `"同步模板"` / `"template changed"` → full run T1→T6
- `"更新所有文档"` / `"刷新所有文档"` / `"refresh all docs"` → skip T1/T3/T4, run T4a2 + T4b + T5, skip T6

This workflow normalizes frontmatter field order, field names, device tracking, body section structure, and refreshes live data (stars, dates, changelog).

### Step T1: Read the Template

1. Read `{TEMPLATE}`
2. Parse the frontmatter: capture field names and their exact order
3. Parse the body: identify all `##` section headers and their order
4. Note any changes from the previous template state (e.g., field added/removed/renamed, section added/removed/renamed)

### Step T2: Scan All Vault Files

Walk ALL `.md` files under `{VAULT_BASE}`.

### Step T3: Normalize Frontmatter Per File

Apply [Frontmatter Normalization Rules](#frontmatter-normalization-rules) to every file, plus template-specific checks:

| Check | Action |
|-------|--------|
| Field name doesn't match template | Rename to match template exactly |
| Field removed from template (e.g., `tags:`) | Remove the field from all files |
| Field added to template (e.g., `使用平台:`) | Add the field with default value |

**Device detection:** Follow [使用设备 判定规则](#使用设备-判定规则) for each file.

Update `使用设备:` based on detection result:
- Installed → `使用设备:\n  - Mac Mini`
- Not installed → `使用设备: N/A`

### Step T4: Normalize Body Section Structure

If the template has added, removed, or reordered body sections:

1. Map each file's existing sections to the template's section order
2. Remove sections that no longer exist in the template (e.g., `参考链接`)
3. Add new empty sections from the template (e.g., `用法`)
4. Reorder sections to match template order
5. Run `scripts/fix-format.sh "{VAULT_BASE}/辅助工具"` — reads each section's structural skeleton from `{TEMPLATE}` and wraps content in the correct callout blocks, `<details>` tags, or table headers; preserves text content

### Step T4a: 模板节内容 — 补空模式

**Scope:** ALL `.md` files under `辅助工具/` that have empty or missing `{TEMPLATE}` sections.

**Goal:** No file should have empty sections. Every section must contain meaningful content derived from internet research.

**Execution:**

1. **Read `{TEMPLATE}`** to determine section list and writing rules for each section.

2. **Scan for gaps:** For each file, check which sections from `{TEMPLATE}` are missing or contain only `> ` / whitespace.

3. **Identify the tool/skill:** Derive the tool name from the filename (strip `NN-` prefix, convert Pascal-kebab to natural name) or from `简介`.

4. **Internet research (do one of):**
   - If the tool has a `GitHub 链接` → open the GitHub README, extract relevant section content
   - If the tool is from a known collection (Anthropic/MattPocock/Superpowers/AddyOsmani/GStack) → search web for the skill's documentation
   - If the tool is a CLI/package → search web for its official docs
   - Use `websearch` tool with query: `"{tool-name} AI agent skill documentation"` or `"{tool-name} CLI tool features"`

5. **Fill each section per `{TEMPLATE}` writing rules.**

6. **Content rules:**
   - Content must be in Chinese (except code blocks, URLs, proper nouns)
   - Do NOT copy placeholder text from the template
   - Base content on actual research, not speculation
   - If web research yields no results, derive content from the existing `简介` section
   - After filling, verify the file reads naturally as a complete document

**Batching:** Process files in parallel by category (Skills/, Skills-Packs/*, 工具/, MCP/, 插件/). For large packs, split into sub-batches.

### Step T4a2: 模板节内容 — 全量刷新模式

**Triggers:** `"更新所有文档"` / `"refresh all docs"` — skips T1/T3/T4, runs T4a2 + T4b only.

**Scope:** ALL `.md` files under `辅助工具/`.

**Goal:** Every section in every file is re-checked against current source material. Existing content is kept unless new information is found.

**Execution:**

1. For each file, derive the tool name from the filename (strip `NN-` prefix, convert Pascal-kebab to natural name) and get `GitHub 链接`.

2. **Research current source:**
   - Has `GitHub 链接` → fetch README, compare against current vault content section by section
   - From a known collection → search web for updated documentation
   - CLI/package → check official docs for changes

3. **Update sections where new info found:**
   - Refer to `{TEMPLATE}` for the canonical section list
   - Only write if there is new information — otherwise leave unchanged

4. **Append to `更新功能`:**
   - If any section was updated → add entry: `"YYYY-MM-DD: 更新 [section]"`.
   - If no changes → no new entry (T4b handles the `"无"` case).

**No per-file confirmation — batch and report.

### Step T4b: 数据刷新

For every `.md` file under `辅助工具/`:

1. **GitHub Star** — fetch 对应 repo 页面, 解析星标数后写回
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
3. Present a summary with counts per operation
4. If any files couldn't be parsed correctly, report them as errors and do not modify them.

### Step T6: Update Template Hash

1. Run `md5 -q "{TEMPLATE}"` to compute the new template hash
2. Update `metadata.template_hash` in this SKILL.md's frontmatter to the new hash
3. Update `metadata.template_checked` to today's date
4. Confirm to the user: "模板哈希已更新，后续将自动检测变更"

## Standardize Workflow（全面标准化）

**Trigger:** `"标准化所有文档"` / `"standardize all docs"` — runs every vault-wide fix in sequence, from formatting to data refresh to renumbering.

Runs the following workflows in sequence, batching and reporting at the end:

1. **[Fix Workflow](#fix-workflow)** — fix format issues (F1-F3)
2. **[Sync Workflow](#sync-workflow-clean-and-re-sort)** — normalize frontmatter, device tracking, re-sort (S1-S6)
3. **[Template Sync T4a](#step-t4a-模板节内容--补空模式)** — fill empty sections via web research
   - Before starting, ask the user: "是否需要联网填充所有文件的空白节？这会产生大量网络请求。"
   - If declined, skip to step 4
4. **[Template Sync T4b](#step-t4b-数据刷新)** — refresh star counts, dates, changelog
5. **[Template Sync T5](#step-t5-verify-and-report)** — verify and report
6. **[Template Sync T6](#step-t6-update-template-hash)** — update template hash

---

## Fix Workflow

Triggered by `"修复文档/修复格式/检查格式"` / `"fix docs"`. Scans vault for known format issues and fixes them. Does NOT renumber, refresh data, or sync templates.

### Step F1: Scan All Vault Files

Walk ALL `.md` files under `{VAULT_BASE}`.

### Step F2: Check and Fix Known Issues

| Check | Detection | Fix |
|-------|-----------|-----|
| `aliases` 含 `@` 前缀 | Parse frontmatter, aliases value starts with `@` | Remove `@` prefix, keep rest of text |
| `aliases` 少于 3 条或格式不规范 | 英文名含连词符、中文名非分类名、条目数 < 3 | 按 Aliases 规范修复：英文名去连词符、中文名改为分类名、补核心技术关键词 |
| frontmatter YAML 解析错误 | Parse each file's YAML frontmatter; catch errors (delimiters, alignment, illegal chars) | Fix formatting and re-parse until clean |
| `ℹ️ 基本介绍` callout 中含裸 `[abstract]`（无 `!`） | `section_has_skeleton` rejects if content has >1 `[!abstract]` line | Run `fix-format.sh` — strips and re-wraps cleanly |
| `ℹ️ 基本介绍` 缺少 `**状态**` 行 | `validate_section_format` checks `**状态**` existence | Run `fix-format.sh` — appends `> **状态**：<span style="color:var(--color-green)">待评估</span>` |
| *(Add rows as new format issues are discovered.)* | | |

For each file:
- Detect which checks trigger
- Apply fixes
- Track what was changed

### Step F3: Report

Present a summary with file counts per issue type. If no issues found, say so.

## Edge Cases

| Case | Handling |
|------|----------|
| No GitHub repository | Set `GitHub 链接: ⚠️ Unknown`, `GitHub Star: N/A` |
| Star count format varies | Parse: `12K` → 12000, `1.5K` → 1500, `N/A` → 0 |
| Empty non-template files (e.g. OPENdesign.md) | Skip — no frontmatter, not a tool document |
| Multiple files share the same star count | Sort alphabetically by tool name |
| File rename fails during renumbering | Stop and report which file failed |
| Hostname not found in Vault Configuration | Ask user to identify the current device |
| Tool install detection is ambiguous | Check multiple methods (`which`, `brew list`, etc.) |
| Cross-device sync conflict | 设备 A 修改后推送 → 设备 B 需重新运行 Sync |
