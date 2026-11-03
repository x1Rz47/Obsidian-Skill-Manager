---
name: obsidian-skill-manager
description: Use when the user asks to install, download, add, set up, deploy, or sync software components. Also use when vault documentation needs fixing, format-checking, or template syncing. Also use when the user says "更新目录", "重新分类", "重新编号", "重整", fix docs, fix format, "修复文档", "修复格式", or "检查格式". Compatible with any SKILL.MD-based AI coding assistant.
---
<!-- WARNING: All section lists must be read from TEMPLATE.MD, never hardcoded. -->

# Obsidian Skill Manager

## Triggering

This skill activates in three modes:

| Mode | Trigger phrases |
|------|----------------|
| **Document** | "记录 [工具]"、"给 [工具] 写个文档"、"doc [tool]"、"更新目录"/"重新分类"/"重新编号"/"重整" |
| **Deploy** | "安装/下载/部署/install/setup/add/deploy" |
| **Fix** | "修复/检查/同步/清理/模板变了/更新模板/同步模板/文档有问题/格式乱了/文档坏了/fix/format/sync/template changed/标准化所有文档/全面标准化/standardize all docs" |

## Vault Configuration

`{TEMPLATE}` = `{SKILL_DIR}/TEMPLATE.MD`.

### Device → Vault Mapping

Variables are resolved at runtime:

| Variable | Source |
|----------|--------|
| `{HOSTNAME}` | `hostname -s` (macOS) / `hostname` (Windows) |
| `{SKILL_DIR}` | Auto-detected from skill install location |
| `{VAULT_BASE}` | Looked up from `{SKILL_DIR}/SKILL.LOCAL.MD` by hostname |
| `{SCOPE}` | `{VAULT_BASE}/01.辅助工具/` (computed from `{VAULT_BASE}`) |
| `{TEMPLATE}` | `{SKILL_DIR}/TEMPLATE.MD` |

Resolution order:
1. If `{SKILL_DIR}/SKILL.LOCAL.MD` exists, read its **Device Configuration** table
2. Match `{HOSTNAME}` against the table → determines `{VAULT_BASE}`
3. If no match or no local config → ask user for their hostname and vault path

### Operational Scope

This skill manages **only** documents under `{SCOPE}` (`{VAULT_BASE}/01.辅助工具/`). (Exception: hub-index maintenance and `[[link]]` repair may touch files outside `{SCOPE}` — the index and cross-references live there; never modify their body content.) Any `.md` files elsewhere in the vault (e.g. `{VAULT_BASE}/02.工具使用/`) are **out of scope**: they are never scanned, searched, updated, restructured, installed, or format-repaired by any workflow in this skill. All workflows below operate on `{SCOPE}` only, unless a user explicitly passes a path inside it.


## Rules

### Classification Rule

All levels are classified by **ability domain**. Core question: **"What capability does this tool give an AI Agent?"**

### Type Rule

The `类型` field marks the tool's technical form, independent of directory location.

**Format:** YAML list, one tool can have multiple types.

```yaml
类型:
  - CLI
  - MCP
```

| Value | Meaning | Example |
|-------|---------|---------|
| `Agent` | Autonomous AI Agent or orchestration framework | Deep-Agents, Remote-OpenCode |
| `Skill` | Agent-executable SKILL.MD instruction set | BrowserAct, Playwright, Agent-Reach |
| `Agent-Plugin` | Runtime extension injected into Agent | Supermemory, Morph, Vibeguard |
| `Guide` | Reference doc / methodology / workflow guide | Cheat-On-Content, Obsidian-Markdown |
| `MCP` | Model Context Protocol server | MarkItDown, CodeGraph, GBrain |
| `CLI` | Command-line standalone tool | yt-dlp, Repomix, DesktopCtl |
| `Library` | Programming library / SDK / Python package | PyAutoGUI, AISuite, GPT-SoVITS |
| `API` | Cloud service / API endpoint | (none yet) |
| `GUI` | Desktop GUI application | OmniVoice-Studio, AISuite |
| `Web` | Web application | Ian-Xiaohei-Illustrations, SkillOpt |
| `Plugin` | External software plugin (e.g. Obsidian plugin) | Claudian, Obsidian-Agent-Client |
| `Model` | AI model / dataset | (none yet) |
| `Collection` | Resource collection repo (doc-only management) | Superpowers, Anthropic, GStack |

**Rules:**
- Value must come from the table above, no custom values
- At least 1, recommended no more than 3
- Multiple types ordered by priority: Agent → Skill → MCP → CLI → Library → API → Agent-Plugin → Plugin → Guide → GUI → Web → Model → Collection
- Type is independent of directory location; files in the same directory can have different types

### Directory Hierarchy Rule

**Format:** `{VAULT_BASE}/01.辅助工具/{L1}/{L2}/{L3}/{L4}/{NN}-{name}.md`

| Level | Creation condition | Description |
|-------|-------------------|-------------|
| **L1** | Never merged/split due to file count | A single file gets its own directory |
| **L2-L4** | Create subdirectory when sub-ability has **≥2** files | Recursive; all 13 types in same directory count as same category |

**Rules:**
- L1 name: `{NN}-{Chinese ability domain name}` (NN = `01`-`99`), assigned consecutively by pinyin sort, for display ordering
- L2/L3/L4 name: `{NN}-{Chinese sub-ability domain name}`, NN assigned independently per parent directory
- L1's `NN-` prefix is for directory ordering; file `NN-` is independent per directory — they don't conflict
- No technical type restriction; all 13 types in the same directory count as same category

**Pre-creation check:** When a directory has ≥2 files belonging to the same sub-ability domain, create a subdirectory:
1. Ensure each file's `aliases` contains the Chinese sub-ability domain name (without NN prefix); append if missing
2. Extract Chinese domain names from files (may have multiple, e.g. `视频制作`, `语音合成`)
3. Create `{NN}-{Chinese sub-ability domain name}` subdirectory for each domain; NN assigned consecutively by pinyin
4. Existing docs: move into subdirectory, reassign numbers by GitHub stars descending
5. New docs: name as `{NN}-{English-name}.md`, NN continues from current directory's max number

**Hard threshold — no discretion:** the ≥2 condition is mechanical, not advisory. When 2+ files in the same directory share a sub-ability domain, split — even if the resulting subdirectory holds only 2 files, and even if you judge the directory "small enough". Do not balance "avoid fragmentation" against the rule; a 2-file subdirectory is correct output. After each operation, re-scan all directories (L2→L4) for remaining clusters.

### Naming Rule

**Format:** `{NN}-{English-name}.md`
- `NN`: Two-digit number (`01`, `02`...`99`)
- `English-name`: PascalCase, hyphen-separated, English only
- Example: `12-Playwright.md`, `04-Data-Visualization.md`

**Rules:**
- Only letters, digits, hyphens, and Chinese in official names
- Each word starts with uppercase, hyphen-separated (e.g. `Data-Visualization`)
- Exception: preserve the tool's original official name (e.g. `PyAutoGUI`, `BrowserAct`, `ian-xiaohei-illustrations`), don't force-hyphenate or translate
- No spaces, no underscores, no other special characters
- No type suffix: filenames must not contain `-mcp`, `-plugin`, `-skill` — directory path already expresses the type
- Remove vendor prefix: `opencode-X` → `X`, `vscode-X` → `X`, unless the prefix is part of the official name
- Template files (`00-*`) are not numbered
- Each directory is numbered independently (including L3 subdirectories)


### Alias Rule

Each file's `aliases` follows these rules, max **5** entries:

| # | Entry | Rule | Example |
|---|-------|------|---------|
| 1 | English name | If exists, write it. PascalCase without hyphens, one only | `BrowserAct` |
| 2 | Chinese name | If exists, write it. The directory's Chinese ability domain name (without NN), position-free | `视频制作` |
| 3+ | Core tech keywords | At least 1, extracted from doc intro/core functions, can have multiple | `浏览器控制`, `Web自动化` |

**Uniqueness:** an alias must not collide with another doc's alias across `{SCOPE}` (case-insensitive) — two docs share an alias (e.g. two "Playwright" docs) means one of them is a duplicate; resolve via I2 uniqueness check before writing. Aliases with different letter-casing (`egolite` vs `Egolite`) count as duplicates: keep the tool's official casing as entry 1, prefer the common lowercase form users actually type as a keyword entry.

### Frontmatter Rule

Shared by **Doc Management**, **Tool Deploy**, and **Format Repair** workflows. Check every `.md` file before any other workflow logic:

| Check | Fix |
|-------|-----|
| `Field order` wrong | Reorder by `{TEMPLATE}`'s frontmatter key order |
| `类型:` missing | Add as YAML list; values from [Type Rule](#type-rule) |
| `类型:` not a list | Convert to YAML list: `类型: X` → `类型:\n  - X`; append all values for multiple types |
| `使用平台:` invalid | Generic tools use `ALL`; Agent-specific tools choose from `OpenCode / Codex / Claude Code / Gemini` separated by ` / `. No `NO`, `N/A` etc. |
| `使用设备:` format error | Fix to YAML list (`  - Device`) or `N/A` |
| `使用设备:` missing | Detect current device install status: if installed append device name (skip if exists), if not installed set `N/A` |
| Booleans not lowercase | Fix: `True` → `true`, `False` → `false`, `Yes` → `yes` |

**Line endings:** every file in this skill and every doc written to `{SCOPE}` must use LF. CRLF in `{TEMPLATE}` silently breaks all `grep "^## section$"` checks in bash (every file reports phantom "非标准段/缺失段"); CRLF in scripts breaks bash entirely (`command not found`). Before diagnosing "all files broken", check `file TEMPLATE.MD` first.

### Document Rule

Document body must strictly follow `{TEMPLATE}`'s `##` section structure and format. Section writing and examples are in the template itself, not duplicated here.

#### `📝 更新功能` Writing Convention

- When doc has only 1 update record, the description is always `首次创建`
- When doc has 2+ records, the first is `首次创建`, subsequent ones have free content
- Template changes (field add/delete/reorder, restructuring, formatting) are **NOT recorded** in `更新功能`; only new content from web searches is recorded
- Keep update descriptions as short as possible — one sentence summarising what was done

#### Update Operations

When any workflow updates an existing doc, always do the following:

| Field | Action |
|-------|--------|
| `GitHub Star` | Re-fetch from web, update to latest; keep original if fetch fails |
| `更新日期` | Set to today `YYYY-MM-DD` |
| `更新功能` | Only append when new content is found via web search; template changes are not recorded |
| `已有内容` | Merge new info into relevant sections; when old and new conflict, overwrite with new |
| `创建日期` | **Never change** |
| `使用设备` | Detect current device install status: if installed append device name (skip if exists), if not installed set `N/A` |

### Installation Detection Rule

| Type | Detection method | Example |
|------|------------------|---------|
| CLI | `which <tool>` (Mac) / `where.exe <tool>` (Win) | `ffmpeg` |
| brew package | `brew list <pkg>` (Mac only) | `gh` |
| npm package | `npm list -g <pkg>` | `bun` |
| pip package | `pip3 list \| grep <pkg>` (Mac) / `pip list \| findstr <pkg>` (Win) | `openai-whisper` |
| MCP | Same as CLI, detect via package manager (`which` / `brew list` / `npm list -g` / `pip3 list`) | `MarkItDown` |
| Agent / Skill / Agent-Plugin | Try `which <tool>` first; then check **all** agent skill directories: `~/.cc-switch/skills/` (super-source, 167+ skills) / `~/.config/opencode/skills/` / `~/.codex/skills/` / `~/.AGENTS/skills/` / `~/.claude/skills/` / `~/.gemini/skills/`. A tool counts as installed if it exists in **any** of these dirs. Note: cc-switch is the master repo and often the only place a skill exists (e.g. SkillOpt, GBrain) — skipping it will miss real installs | `BrowserAct`, `SkillOpt` (only in opencode), `GBrain` (only in cc-switch + opencode) |
| GUI | `ls /Applications/*.app` (Mac) / `which <tool>` | `OmniVoice-Studio` |
| Web | Cannot detect install state, always `N/A` (web apps have no local installation) | `Ian-Xiaohei-Illustrations` |
| Collection / Guide / Model | Not installable, always `N/A` | `GStack`, `Superpowers` |


## Workflows

## Schema Architecture

Document validation is **schema-driven**, not pattern-matching. The single source of truth is `SCRIPTS/SCHEMA.py` (Python dict). `SCRIPTS/VALIDATE_SCHEMA.py` reads the schema and strictly checks every file:

- Frontmatter field completeness + order
- Section structure completeness + order (non-standard sections rejected)
- Per-section skeleton (abstract/info/warning callout, plain_list, prereq_list, table_header, details_blocks)
- Global forbidden patterns (URL/command hidden in comments, HTML-in-list, TEMPLATE placeholders, `> [!quote]` in 🧩)
- Cross-section structures (duplicate `---`, aliases uniqueness)

`VALIDATE-FORMAT.SH` (bash, legacy) calls `VALIDATE_SCHEMA.py` after its own checks pass. To change validation rules, edit `SCHEMA.py` — not the bash functions. The old bash checks in `LIB.SH` are retained for backward compat but the Python schema is authoritative.

**Closing check for every workflow** (cheap, catches most regressions):
```bash
SCRIPTS/VALIDATE_SCHEMA.py "{SCOPE}"
```
Run it after any write (create / update / rename / renumber) and include the result (total files / total errors) in the report. A workflow that ends with schema errors is not done.

**Hub index maintenance**: renames, new docs, and category changes must be reflected in `{VAULT_BASE}/00.索引-*.md` (section counts and `[[NN-Name]]` links live there). When a rename breaks links, `grep -rl "\[\[旧名\]\]"` the whole vault — links to `{SCOPE}` docs exist outside `{SCOPE}` too.

### Doc Management Workflow

Core: Document management. Handles links, tool names, batch updates, and full vault updates.

#### I1: Parse Input

| Input type | Action |
|------------|--------|
| GitHub link (`https://github.com/owner/repo`) | Extract tool name, GitHub URL, infer tool type |
| Tool name (`ffmpeg` / `Playwright`) | Search vault by name |
| Multiple tools (`ffmpeg, git, vscode`) | Parse list, process each |
| "所有" / "全部" / not specified | Traverse all docs under `{SCOPE}`, process each |
| "更新目录" / "重新分类" / "重新编号" / "重整" (without a tool name) | Full vault directory restructure → skip to I3DirRestructure |

#### I2: Search & Match

Determine `{VAULT_BASE}` via [Device → Vault Mapping](#device--vault-mapping).

Search targets:
- **GitHub link** → extract `owner/repo`, search globally by `GitHub 链接` field across `{SCOPE}`
- **Tool name** → recursively search `{SCOPE}` all `.md` files, match by filename (without `NN-` prefix) or `aliases`
- **Multiple tools** → search each tool separately
- **"所有"** → target is all docs under `{SCOPE}`

**Classification sanity check** (run when a doc's category is questioned, or on "重新分类"):
1. Read the doc's abstract — does the L1/L2 category describe **what the tool does**, not where it was first dumped? A learning app does not belong in 媒体创作; a publishing skill does not belong in 视频制作; a generic research/teaching skill does not belong in Obsidian生态.
2. Same GitHub repo split across multiple docs (e.g. one repo → 4 sub-skill docs) is a dedup violation: keep the sub-skill split only if each doc has distinct real content; otherwise merge.
3. Stub docs (abstract is one short sentence, `<details>` blocks contain template-echo text like "提供XX功能") are low-quality: mark `⚠️ stub` and offer F4 content completion.
4. Move = `mv` + update `aliases[1]` to the new directory's Chinese domain name + renumber by stars + rebuild hub index + schema validation.
5. **No matching category exists → create a new L1 directory** (`{SCOPE}/{NN}-{中文能力域}` with the next free NN; emoji allowed in L1 names). Do not force a doc into a semantically wrong category just to avoid creating a directory. After creating: place docs inside (renumber by stars), add the new section to `{VAULT_BASE}/00.索引-*.md`, keep L1 numbering gap-free (renumber sibling L1 dirs if a middle number was vacated).
6. **No catch-all category names.** An L1/L2 name must state the ability domain it collects (e.g. `跨境电商`, `测试质量`) — never a placeholder like `领域技能` / `其他` / `杂项` / `临时`. A "doesn't fit anywhere" doc means either (a) the doc's real ability domain should become its own category, or (b) the doc belongs in an existing category under a different facet. Re-evaluate on every insertion; never let a catch-all absorb new docs.

Results:
- **Specific doc found** → I3 (update content)
- **Full vault (from I1 "所有/全部")** → I3FullVault (full vault update)
- **Not found** → I3d (generate new doc)

#### I3: Update Specific Doc

For GitHub links, tool names, batch lists.

- Fetch latest GitHub star count from page
- Check repo changelog: has updates → append `- YYYY-MM-DD: <summary>`; no changes → `"No changes (data already synced)"`
- User provided new info → prefer merging user content
- Apply [Document Rule](#document-rule)

---

#### I3FullVault: Full Vault Update

For "所有" / "全部".

- Fetch GitHub star count for all files (keep original if fail)
- Set `更新日期` to today
- Skip `更新功能` appending (too many files, don't check changelog per file)
- Skip user content merging
- Check [Directory Hierarchy Rule](#directory-hierarchy-rule) and [Naming Rule](#naming-rule) grouped by directory; fix issues as found

---

#### I3DirRestructure: Full Vault Directory Restructure

For "更新目录", "重新分类", "重新编号", "重整".

1. Determine `{VAULT_BASE}` via [Device → Vault Mapping](#device--vault-mapping)
2. Scan all `.md` files in `{SCOPE}`, parse frontmatter
3. Reclassify by [Directory Hierarchy Rule](#directory-hierarchy-rule):
   - Identify each file's sub-ability domain
   - Create/merge L2-L4 subdirectories
4. Renumber all files by GitHub stars descending (`NN-English-name.md`)
5. Fix filenames and aliases by [Naming Rule](#naming-rule) and [Alias Rule](#alias-rule)
6. **Do not modify any doc body content**, leave `创建日期`, `更新日期`, `GitHub Star` etc. untouched
7. **After renumbering**, repair links: update all `[[NN-Name]]` wiki links pointing to renamed files (search the whole vault, not just `{SCOPE}` — the hub index and cross-references live outside it), refresh hub index counts, then run `SCRIPTS/VALIDATE_SCHEMA.py "{SCOPE}"` to confirm 0 errors

---

#### I3d: Not Found → Full Research → Generate Doc

Collect the following info:
- Official README / doc introduction
- GitHub link and star count (via search engine or GitHub API)
- Install command
- Core features, dependencies, `使用平台`
- Known limitations or notes

If GitHub fetch fails, set `GitHub Star: N/A`.

**Star-fetching fallback order** (GitHub API is rate-limited to 60/h unauthenticated; do not stop at the first failure):
1. GitHub API `api.github.com/repos/{owner}/{repo}` → `stargazers_count` (round: `21449` → `21.4K`)
2. GitHub API blocked → fetch the repo HTML page and parse `"stargazerCount":\s*(\d+)`
3. Both fail → retry once after 60s, then keep the original star and mark `⚠️ network_error` in the report

**Uniqueness check before writing** (dedup gate — run every time):
1. Search `{SCOPE}` for the same `GitHub 链接` (normalised, trailing `/` stripped, lowercase) — if found, this is an **update**, not a new doc: route to I3 and stop here
2. Search for same/similar tool name in `aliases` and filename (case-insensitive, ignore `-`/space differences) — if found with a different repo, ask the user which one to keep
3. Never create a second doc for a tool that already has one under a different category

Generate doc with researched data:
- Read `{TEMPLATE}` to get field order, section structure, and writing rules
- Fill `GitHub 链接`, `GitHub Star`, intro, core features, `使用平台`
- Set `创建日期` and `更新日期` to today
- Set `使用设备` to current device

Check [Directory Hierarchy Rule](#directory-hierarchy-rule) before writing:
- If directory has ≥2 files in same sub-ability domain → create subdirectory, move files, renumber, then write
- Otherwise:
  1. Read `GitHub Star` from all existing `.md` files in the target directory (`N/A` sorts last, `0` as number 0)
  2. Sort existing files by stars **descending**, determine where the new file's star count would be inserted
  3. **Renumber all affected files**: target gets `{insertion-NN}`, every subsequent file gets `NN+1` (rename the file)
  4. Write to `{SCOPE}/{category}/{NN}-{English-name}.md`

**After any rename**, repair links:
1. Update all `[[NN-Name]]` links to the renamed docs across the whole vault (at minimum `{SCOPE}`'s hub index)
2. Rebuild/refresh the hub index (`{VAULT_BASE}/00.索引-*.md`) row count and section counts
3. Run `SCRIPTS/VALIDATE_SCHEMA.py "{SCOPE}"` and fix any reported error before reporting done

Tell user: "Document generated: {filename}"

#### I4: Report

Summary:

| Metric | Value |
|--------|-------|
| Files created | {n} |
| Files updated | {n} |
| Files restructured | {n} |
| Unchanged | {n} |
| GitHub Star changes | List changes |

- **Specific docs**: List each file's update details (`{file}: star {old}→{new} | changelog {updated/no change}`)
- **Full vault / directory restructure**: Group by directory, show file counts and change summary

### Tool Deploy Workflow

#### D1: Parse Command

| You say | Behavior |
|---------|----------|
| "安装所有" / "安装" (no type specified) | `必用: true` |
| "安装 <type>" (e.g. "安装 MCP" / "安装 skills" / "安装 CLI") | `必用: true` + `类型` contains specified value |

#### D2: Detect Device + Scan & Match

1. Determine current device:
   - Read `SKILL.LOCAL.MD`, get current hostname (`hostname -s`)
   - Look up `{VAULT_BASE}` from device config table
   - If not found, ask user for hostname and path
2. Recursively traverse all `.md` files in `{SCOPE}`, parse frontmatter
3. During scan, detect frontmatter issues: missing fields, wrong order, format errors. Report immediately and suggest "Run format repair workflow", **do not auto-fix**
4. Filter by D1 conditions:
   - **"安装所有"** → `必用: true`
   - **"安装 <type>"** → `必用: true` + `类型` contains specified value
5. If no match, report and stop

#### D3: Select & Install

1. Detect install status for each matched file via [Installation Detection Rule](#installation-detection-rule), show summary table:

   | Tool name | Type | Status |
   |-----------|------|--------|
   | ffmpeg | CLI | ✅ Installed |
   | BrowserAct | Agent | ❌ Not installed |

   "{n} tools total, {x} installed, {y} not installed"
   If all installed, report and stop.

2. Show multi-select list of not-installed tools, let you check which ones to install
3. Install selected tools one by one:
   - If tool's doc has install command → follow it directly
   - If doc has no install command → search official install docs online
4. Verify after install: re-run [Installation Detection Rule](#installation-detection-rule)
   - Failure → ask "Retry this tool?", if yes reinstall current tool, otherwise skip and log
5. On success, update `使用设备`: append current device name (skip if exists; replace if `N/A`)
6. Log each tool's result

#### D4: Report

Show install details grouped by result:

| Tool name | Type | Result | Note |
|-----------|------|--------|------|
| ffmpeg | CLI | ✅ Success | verified by `which ffmpeg` |
| BrowserAct | Agent | ❌ Failed | copy failed: permission denied |
| yt-dlp | CLI | ⏭️ Skipped | not selected |
| Superpowers | Collection | ➖ Not installable | type not supported |

Summary: "{n} tools: {s} success, {f} failed, {k} skipped"
For failed tools, ask "Retry" or "Skip".

### Format Repair Workflow

Trigger: "文档有问题", "修复文档", "修复格式", "检查格式", "fix format", "格式乱了", "文档坏了", "模板变了", "更新模板", "同步模板", "template changed", "标准化所有文档", "全面标准化", "standardize all docs".

Executed when doc formatting is broken. Covers template sync, format repair, and content completion.

- Trigger contains "模板" → full `{SCOPE}` mode, skip F4 (structure sync only, no content fill)
- Other triggers → determine scope via F1

#### F1: Determine Scope

- **User specified a path** → determine if file or directory:
  - Relative paths are resolved against `{SCOPE}`
  - Directory = recursively process all `.md` files in it
- **Not specified** (e.g. "修复格式" / "文档有问题") → traverse all `.md` files under `{SCOPE}`

#### F2: Template Sync

For each file in scope: read template (first time only), align field names (add/delete/rename fields), section structure (add/delete/reorder sections) against template, then run `FIX-FORMAT.SH` to fix skeleton.

Files that fail template sync are marked `⚠️ template_exception`, skip F3-F4.

#### F3: Format Repair

For each file in scope, check and fix in the following module order:

**Module A — Frontmatter**

| Check | Detection | Fix |
|-------|-----------|-----|
| Missing fields | Compare against template field list (aliases/类型/GitHub 链接/GitHub Star/使用设备/使用平台/创建日期/更新日期/必用) | Fill missing fields per template |
| Wrong field order | Check order | Reorder per template |
| Field format error | Date not `YYYY-MM-DD`, `GitHub Star` format wrong, `必用` not boolean | Fix per [Frontmatter Rule](#frontmatter-rule) |
| Empty field content | `GitHub 链接` is empty/placeholder, `GitHub Star` empty | Mark as `⚠️ pending`, F4 will fix via web search |
| `aliases` has `@` prefix | YAML parse, value starts with `@` | Remove `@` |
| `aliases` < 3 entries or bad format | Entry count < 3, English name has hyphens, Chinese name not category name | Fix per [Alias Rule](#alias-rule) |
| `aliases` has duplicates | Parse aliases list, find duplicate values (case-sensitive, ignore ~~ strikethrough marks during comparison) | Remove duplicate entries, keep first occurrence |
| frontmatter `aliases` strikethrough not deleted | Raw markdown has `~~value~~` in aliases (Obsidian UI shows red strikethrough but content remains) | Remove the entry or clean the `~~` marks |
| `类型` invalid | Missing, not a list, invalid value | Fix per [Type Rule](#type-rule) |
| `使用平台` invalid | Generic tool not `ALL`, Agent tool not platform list | Fix per [Frontmatter Rule](#frontmatter-rule) |
| `使用设备` missing/format error | Not YAML list nor `N/A` | Fix per [Frontmatter Rule](#frontmatter-rule) |
| Booleans not lowercase | `True`/`False`/`Yes`/`No` | Fix to lowercase |
| YAML parse error | Frontmatter parse fails | Fix format until it passes |
| Directory sorting violation | Files not NN-numbered in GitHub Star descending order (N/A last, ties by filename asc) | Reorder NN prefixes per [Naming Rule](#naming-rule) |

**Module B — Body Structure**

| Check | Detection | Fix |
|-------|-----------|-----|
| Section callout/skeleton anomaly | Expected skeleton per template (`[!abstract]`, `[!info]`, `[!warning]`, `<details>`, table, list) | Run `FIX-FORMAT.SH` |
| Non-standard section present | File has `## ` section not in TEMPLATE (e.g. `📖 使用技巧`, `❓ 常见问题`, `📌 备注`) | Merge content into standard sections, delete the non-standard section |
| Section order wrong | File sections not in TEMPLATE's 9-section order (ℹ️→🎯→📦→💿→💊→🧩→⌨️→⚠️→📝) | Reorder sections to match TEMPLATE |
| Missing section | TEMPLATE defines section but file lacks it | Add section with placeholder content per template |
| Section content still TEMPLATE placeholder | Content contains template placeholder text (`依赖项名称` / `具体描述` / `对应的解决方案` / `详细描述第N行` / `功能名+简短说明` / `# 安装命令（brew`) | Fill with real content via web research (F4) |
| URL hidden in code comment | Callout code block contains `> # https://...` (URL commented out instead of being visible) | Remove `#` prefix so URL is selectable, or move to callout exterior as markdown link |
| Slash command hidden in code comment | Callout code block contains `> # /skill xxx` or similar `/command` commented out | Remove `#` prefix so command is selectable; keep real explanatory comments like `# npm 安装` |
| Duplicate adjacent `---` horizontal rules | Two `---` lines with ≤1 blank line between them, except the legitimate pair right after frontmatter (TEMPLATE standard) | Remove the extra `---`, keep only one separator |
| `📝 更新功能` format wrong | Not `- YYYY-MM-DD：（full-width colon）` format | Fix per [Document Rule](#document-rule) |
| `使用设备` install state outdated | Last run recorded a different device; cross-device sync detected | Update per [Frontmatter Rule](#frontmatter-rule) — detect current device, append/set `N/A` |

**Module C — Markdown Format**

| Check | Detection | Fix |
|-------|-----------|-----|
| Callout continuation leading space | Lines after `> [!...]` start with ` > ` | Remove space before `>` |
| Missing blank line before heading after table | `##` directly after `|\n` | Add blank line |
| File doesn't start with `---` | First line not `---` | Add frontmatter delimiter |
| Missing `---` before template-defined section separator | Read section list from {TEMPLATE}, check if each separator `---` is present before its section | Insert |
| Missing `---` at end | File doesn't end with `---` | Append |
| Blank line pattern doesn't match template | Detect throughout: frontmatter after, separator before/after, `##` before/after, end `---` before not exactly 1 blank line, or consecutive blank lines | Normalize per template: exactly 1 blank line between adjacent structural elements, no consecutive blank lines |

For each file in scope: if file doesn't start with `---`, fix frontmatter delimiter first. Then detect remaining items in A → B → C order → apply fixes → track changes.

#### F4: Content Completion

- **Template triggers** → skip F4 (structure sync only)
- **Other triggers** → ask user "Search online to fill blank sections?"
  - **No** → skip F4, go to F5
  - **Yes** → for each file in scope:

1. **Detect blank sections**: compare against template section structure, find empty or placeholder-only sections (e.g. `待补充`, `TBD`, empty callouts)
2. **Search & fill**: priority order — GitHub README > official docs > general web search
   - Determine language preference by tool name/category
   - Only fill blank/placeholder sections, don't overwrite existing content
3. **Search failed**: keep as-is, mark `⚠️ not_found` in report
4. **Network down**: keep already-filled files, mark unfilled as `⚠️ not_found`

#### F5: Report

- **Specific file**: List per-item fix detail — `{file}: A:{n} B:{n} C:{n} F4:filled:{n}sections ⚠️: template_exception:{n} | not_found:{n} | pending:{n}`
- **Full vault**: Show file count summary by issue type

If no issues, report honestly.

Report also lists all markers generated during this repair (`⚠️ pending` / `⚠️ template_exception` / `⚠️ not_found`) for reference by other workflows.

### Edge Cases

| Workflow | Case | Handling |
|----------|------|----------|
| General | Hostname not found in vault config | Ask user for their hostname and vault path |
| General | Tool install detection ambiguous | Priority: `which` → `brew list` → `npm list -g` → `pip3 list` |
| General | File locked / cannot read/write | Skip file, report `⚠️ file_locked`, ask user to close and retry |
| General | GitHub API rate limit / network failure | Retry after 60s; after 3 failures mark `⚠️ network_error`, skip online steps |
| General | Filename contains illegal characters | Filter per [Naming Rule](#naming-rule) |
| General | `{VAULT_BASE}` path doesn't exist | Ask user to check `SKILL.LOCAL.MD` path config |
| General | `{TEMPLATE}` file missing | Ask user to reinstall skill |
| General | Vault directory has no `.md` files | Report "No documents found", stop |
| General | GitHub Star is 0 | `0` sorts as number 0 (less than all positive numbers), `N/A` sorts last |
| General | Skill repo synced from cloud storage | Files may arrive CRLF; if bash errors (`command not found` on shebang lines) or every file fails section checks, convert CRLF→LF first (see Frontmatter Rule line-endings) |
| General | Python `ModuleNotFoundError: schema` on network volumes (SMB/NFS) | `sys.path` lookup is unreliable on SMB mounts; `VALIDATE_SCHEMA.py` uses explicit `importlib.util.spec_from_file_location` — keep that pattern when editing |
| Format Repair | Cross-device sync | After vault sync (SynologyDrive/other cloud), device B needs to run Format Repair workflow to update `使用设备` etc. |
| Doc Management | Doc sits in a category unrelated to its function | Run the classification sanity check in I2; move to the ability-domain directory, never leave a doc where it was first dumped |
| Doc Management | Same repo split into multiple docs (sub-skills) | Allowed only if each doc has distinct real content; stub-quality duplicates → merge into one doc |
| General | Another device is writing the same vault | Before ANY bulk operation (restructure, batch update, full-vault fix): check for recent writes (files modified in the last 30 min) and empty `XX 2`-style / `_Conflict` files; if concurrent writes are detected, stop and ask the user to pause the other device first |
