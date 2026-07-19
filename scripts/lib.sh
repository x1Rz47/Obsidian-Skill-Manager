#!/bin/bash
# lib.sh — Common functions for 知识库 template format operations
# Usage: source "$(dirname "$0")/lib.sh"

SKILL_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
TEMPLATE="$SKILL_DIR/TEMPLATE.md"

# Section → skeleton mapping (no emoji keys: use name suffix for lookup)
# Skeleton types: info_callout, warning_callout, abstract_callout, details_blocks, table_header
# details_blocks 只接受 <details> 折叠块（TEMPLATE 标准），不接受 > [!quote] callout
get_section_skeleton() {
  local section="$1"
  case "$section" in
    "ℹ️ 基本介绍")   echo "abstract_callout" ;;
    "🎯 使用场景")   echo "plain_list"      ;;
    "📦 前置依赖")   echo "prereq_list"     ;;
    "💊 痛点解决")   echo "table_header"    ;;
    "🧩 核心功能")   echo "details_blocks"  ;;
    "⌨️ 使用方法")   echo "info_callout"    ;;
    "⚠️ 注意事项")   echo "warning_callout"  ;;
    "📝 更新功能")   echo "plain_list"      ;;
    *)               echo ""                ;;
  esac
}

get_template_sections() {
  grep "^## " "$TEMPLATE" | sed 's/^## //'
}

# Get line number of section heading (first match)
_section_line() {
  local file="$1" section="$2"
  grep -n "^## $section\$" "$file" | head -1 | cut -d: -f1
}

# Get line number of next ## heading after start_line, or EOF+1
_next_section_line() {
  local file="$1" start_line="$2"
  local total
  total=$(wc -l < "$file")
  awk -v s="$start_line" -v t="$total" 'NR > s && /^## / {print NR; found=1; exit} END{if(!found) print t+1}' "$file"
}

# Get raw content (lines) between heading and next heading
get_section_content() {
  local file="$1" section="$2"
  local start end
  start=$(_section_line "$file" "$section")
  [ -z "$start" ] && return 1
  end=$(_next_section_line "$file" "$start")
  sed -n "$((start+1)),$((end-1))p" "$file"
}

# Replace content between heading and next heading
_set_section_content() {
  local file="$1" section="$2" content_lines="$3"
  local start end tmp
  start=$(_section_line "$file" "$section")
  [ -z "$start" ] && return 1
  end=$(_next_section_line "$file" "$start")
  tmp=$(mktemp)

  {
    sed -n "1,${start}p" "$file"
    echo ""
    [ -n "$content_lines" ] && echo "$content_lines"
    sed -n "${end},\$p" "$file"
  } > "$tmp" && mv "$tmp" "$file"
}

# Ensure all template sections exist in the file in order
ensure_template_sections() {
  local file="$1"
  local missing=""
  local order=""

  # Collect missing sections from TEMPLATE.md
  while IFS= read -r section; do
    if ! grep -q "^## $section\$" "$file" 2>/dev/null; then
      missing="$missing  $section"
      order="$order"$'\n'"## $section"$'\n'
    fi
  done < <(get_template_sections)

  [ -z "$missing" ] && return 0

  # Append missing sections before the trailing --- (or end of file)
  local last_line
  last_line=$(tail -1 "$file")
  if [ "$last_line" = "---" ]; then
    # Insert before trailing ---
    sed '$d' "$file" > "${file}.tmp"
    echo "$order" >> "${file}.tmp"
    echo "---" >> "${file}.tmp"
    mv "${file}.tmp" "$file"
  else
    echo "$order" >> "$file"
  fi

  echo "FIXED → added missing sections:$missing"
}

# Check if section content already has correct structural format
section_has_skeleton() {
  local content="$1" skeleton_type="$2"

  local effective
  effective=$(echo "$content" | grep -v '^[[:space:]]*$' | head -1)

  case "$skeleton_type" in
    info_callout)
      echo "$effective" | grep -q '^> \[!info\]' || return 1
      [ "$(echo "$content" | grep -cE '\[!?info\]')" -gt 1 ] && return 1
      return 0
      ;;
    warning_callout)
      echo "$effective" | grep -q '^> \[!warning\]' || return 1
      [ "$(echo "$content" | grep -cE '\[!?warning\]')" -gt 1 ] && return 1
      return 0
      ;;
    abstract_callout)
      echo "$effective" | grep -q '^> \[!abstract\]' || return 1
      # Reject if more than one [!abstract]/[abstract] line in content body
      [ "$(echo "$content" | grep -cE '\[!?abstract\]')" -gt 1 ] && return 1
      return 0
      ;;
    prereq_list)      echo "$effective" | grep -q '^- '                    ;;
    plain_list)
      # 第一行必须是 list 项
      echo "$effective" | grep -q '^- ' || return 1
      # 检测"HTML 被错误包成 list"模式（每行带 - 前缀的 HTML 块标签）
      # 这种内容格式上像 list，语义上完全错误，validate 必须抓住
      if echo "$content" | grep -qE '^[[:space:]]*- <(table|thead|tbody|tr|td|th|div|p|span|ul|ol|li|details|summary|section|article|header|footer|main|figure|figcaption)\b'; then
        return 1
      fi
      return 0
      ;;
    details_blocks)
      # 🧩 核心功能 段必须用 <details> 折叠块（TEMPLATE 标准）
      # 不再接受 > [!quote] callout 形式——容易和 ℹ️/⚠️ 等抽象 callout 混淆
      echo "$content" | grep -q '<details' || return 1
      return 0
      ;;
    table_header)
      echo "$effective" | grep -q '🔢' || return 1
      # Check column alignment: data rows must have numbers in first column
      local data_rows misaligned cell
      data_rows=$(echo "$content" | grep '^|' | grep -v '🔢' | grep -vE '^\| *[-:]+ *\||^\| *$')
      misaligned=0
      while IFS= read -r row; do
        [ -z "$row" ] && continue
        cell=$(echo "$row" | sed 's/^| *//;s/ *|.*//')
        if [ -n "$cell" ] && ! echo "$cell" | grep -qE '^[0-9]+$'; then
          misaligned=1; break
        fi
      done <<< "$data_rows"
      [ "$misaligned" -eq 1 ] && return 1
      return 0
      ;;
    *) return 0 ;;
  esac
  return $?
}

# Infer status span from GitHub Stars
infer_status_span() {
  local file="$1"

  # Parse GitHub Star from frontmatter
  local star
  star=$(grep '^GitHub Star:' "$file" | sed 's/^GitHub Star: *//' | tr -d ' ')

  local num=0
  if echo "$star" | grep -q 'K$'; then
    local val
    val=$(echo "$star" | sed 's/K$//')
    num=$(awk "BEGIN{printf \"%.0f\", $val * 1000}" 2>/dev/null)
  elif echo "$star" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    num=$(awk "BEGIN{printf \"%.0f\", $star}" 2>/dev/null)
  fi

  if [ "$num" -ge 1000 ]; then
    echo '<span style="color:var(--color-green)">稳定</span>'
  else
    echo '<span style="color:var(--color-orange)">开发中</span>'
  fi
}

# Strip nested/bare callout markers from section content
clean_nested_callout() {
  local content="$1" type="${2:-abstract}"
  echo "$content" | grep -vE "\[!?${type}\]" | sed 's/^[[:space:]>]*//' | grep -v '^[[:space:]]*$'
}

# Strip blockquote prefix (> ) from every line
strip_blockquote() {
  local content="$1"
  echo "$content" | awk '
    /^> / {print substr($0, 3); next}
    /^>$/ {print ""; next}
    /^>\[/ {next}  # skip callout header
    {print}
  '
}

# Wrap content in a callout block: prefix every line with "> "
wrap_in_callout() {
  local content="$1" callout_type="$2"

  # First: strip any existing blockquote prefix
  content=$(strip_blockquote "$content")

  local result="> [!$callout_type]"

  while IFS= read -r line; do
    if [ -z "$line" ]; then
      result+=$'\n'" >"
    else
      result+=$'\n'" > $line"
    fi
  done <<< "$content"

  echo "$result"
}

fix_section_format() {
  local file="$1" section="$2"
  local skeleton_type
  skeleton_type=$(get_section_skeleton "$section")
  [ -z "$skeleton_type" ] && return 0

  local content
  content=$(get_section_content "$file" "$section") || return 0

  # Skip empty sections (except prereq_list and table_header — populate from template)
  if [ "$skeleton_type" != "prereq_list" ] && [ "$skeleton_type" != "table_header" ]; then
    local bare
    bare=$(echo "$content" | grep -v '^[[:space:]]*$' | head -1)
    [ -z "$bare" ] && return 0
  fi

  # Skip already-correct (ℹ️ section always runs post-fix for **状态** formatting)
  if section_has_skeleton "$content" "$skeleton_type" && [ "$section" != "ℹ️ 基本介绍" ] && [ "$skeleton_type" != "table_header" ]; then
    return 0
  fi

  local fixed
  case "$skeleton_type" in
    info_callout|warning_callout|abstract_callout)
      local ct
      case "$skeleton_type" in
        info_callout) ct="info" ;;
        warning_callout) ct="warning" ;;
        abstract_callout) ct="abstract" ;;
      esac
      if section_has_skeleton "$content" "$skeleton_type"; then
        fixed=""
      else
        content=$(clean_nested_callout "$content" "$ct")
        fixed=$(wrap_in_callout "$content" "$ct")
      fi
      [ -z "$fixed" ] || {
        _set_section_content "$file" "$section" "$fixed"
        echo "FIXED $section → > [!${ct}]"
      }
      ;;

    prereq_list)
      # Auto-populate empty 📦 sections with template entries
      local bare
      bare=$(echo "$content" | grep -v '^[[:space:]]*$' | head -1)
      if [ -z "$bare" ]; then
        fixed=$(cat <<'TEMPLATE'
- <span style="color:red">**必选**</span>： 依赖项名称
- <span style="color:green">**可选**</span>： 依赖项名称
- <span style="color:gray">**无**</span>： （无需额外依赖）
TEMPLATE
)
        _set_section_content "$file" "$section" "$fixed"
        echo "FIXED $section → populated with template entries"
      fi
      ;;

    plain_list)
      # Plain-list sections — validate only, no auto-wrap
      ;;

    details_blocks)
      # 🧩 段要求 <details> 折叠块（TEMPLATE 标准）
      # 不自动转换 > [!quote] → <details>（结构解析复杂，交给手工修）
      # section_has_skeleton 已经会报错，这里不做自动转换
      ;;

    table_header)
      local first_line
      first_line=$(echo "$content" | grep -v '^[[:space:]]*$' | head -1)

      # Empty section → populate with template placeholder
      if [ -z "$first_line" ]; then
        fixed=$(cat <<'TEMPLATE_TABLE'
| 🔢 | ❓ 问题 | 💡 方案 |
|:---:|:------|:------|
| 1 | 具体描述 | 对应的解决方案 |
| 2 | 具体描述 | 对应的解决方案 |
| 3 | 具体描述 | 对应的解决方案 |
TEMPLATE_TABLE
)
        _set_section_content "$file" "$section" "$fixed"
        echo "FIXED $section → populated with template table"
      elif echo "$first_line" | grep -qE '^\|.*❌.*✅.*\|$'; then
        fixed=$(echo "$content" | sed '1,/^|/s/|.*|/| 🔢 | ❓ 问题 | 💡 方案 |/')
        _set_section_content "$file" "$section" "$fixed"
        echo "FIXED $section → table header"
      elif echo "$first_line" | grep -q '^- '; then
        # Convert bullet list to table (simple approach)
        local n=0
        fixed=""
        fixed+="| 🔢 | ❓ 问题 | 💡 方案 |"$'\n'
        fixed+="|:---:|:------|:------|"$'\n'
        while IFS= read -r line; do
          if echo "$line" | grep -q '^- '; then
            n=$((n+1))
            local item="${line#- }"
            fixed+="| $n | $item | |"$'\n'
          fi
        done <<< "$content"
        _set_section_content "$file" "$section" "$fixed"
        echo "FIXED $section → bullet list converted to table"
      elif echo "$first_line" | grep -q '^|'; then
        # Unified fix: header + separator + auto-number data rows
        fixed=$(echo "$content" | awk '
          BEGIN { ln=0; n=0 }
          /^\|/ {
            ln++
            if(ln==1) { print "| 🔢 | ❓ 问题 | 💡 方案 |"; next }
            if(ln==2) { print "|:---:|:------|:------|"; next }
            n++

            rest = substr($0, 2)
            gsub(/^[[:space:]]*/, "", rest)
            idx = index(rest, "|")
            cell1 = idx > 0 ? substr(rest, 1, idx - 1) : rest
            gsub(/[[:space:]]+$/, "", cell1)

            if(cell1 ~ /^[0-9]+$/) { print; next }

            rest2 = idx > 0 ? substr(rest, idx + 1) : ""
            gsub(/^[[:space:]]*/, "", rest2)
            idx2 = index(rest2, "|")
            cell2 = idx2 > 0 ? substr(rest2, 1, idx2 - 1) : rest2
            gsub(/[[:space:]]+$/, "", cell2)

            rest3 = idx2 > 0 ? substr(rest2, idx2 + 1) : ""
            gsub(/^[[:space:]]*/, "", rest3)
            idx3 = index(rest3, "|")
            cell3 = idx3 > 0 ? substr(rest3, 1, idx3 - 1) : rest3
            gsub(/[[:space:]]+$/, "", cell3)

            # cell1 has text (misaligned) → keep as col2, number in col1
            if(length(cell1) > 0) {
              print "| " n " | " cell1 " | " cell2 " |"
              next
            }
            # cell1 empty → number it, shift col2/col3 into place
            print "| " n " | " cell2 " | " cell3 " |"
            next
          }
          { print }
        ')
        # Only write if content actually changed
        if [ "$(echo "$fixed" | grep -v '^[[:space:]]*$')" != "$(echo "$content" | grep -v '^[[:space:]]*$')" ]; then
          _set_section_content "$file" "$section" "$fixed"
          echo "FIXED $section → table structure corrected"
        fi
        unset fixed
      fi
      ;;
  esac

  # Post-fix: ensure ℹ️ section has **状态** line with blank line before it
  if [ "$section" = "ℹ️ 基本介绍" ]; then
    local current
    current=$(get_section_content "$file" "$section") || return 0

    # Extract existing status text (preserve it if present)
    local status_text
    status_text=$(echo "$current" | grep '\*\*状态\*\*' | sed 's/.*\*\*状态\*\*：//')
    if [ -z "$status_text" ] || echo "$status_text" | grep -q '待评估'; then
      status_text=$(infer_status_span "$file")
    fi

    # Remove any existing **状态** line
    local no_status
    no_status=$(echo "$current" | grep -v '\*\*状态\*\*')

    # Check if last non-blank line is a blank callout line ( > or >)
    local last
    last=$(echo "$no_status" | grep -v '^[[:space:]]*$' | tail -1)

    if [ "$last" = ">" ] || [ "$last" = " >" ]; then
      fixed="$no_status"$'\n'" > **状态**：$status_text"
    else
      fixed="$no_status"$'\n'" >"$'\n'" > **状态**：$status_text"
    fi

    if [ "$fixed" != "$current" ]; then
      _set_section_content "$file" "$section" "$fixed"
      echo "FIXED $section → **状态** formatted"
    fi
  fi
}

# Validate one section in a 知识库 file
validate_section_format() {
  local file="$1" section="$2"
  local skeleton_type
  skeleton_type=$(get_section_skeleton "$section")
  [ -z "$skeleton_type" ] && return 0

  # Check section header exists in the file
  if ! grep -q "^## $section\$" "$file" 2>/dev/null; then
    echo "  ❌ $(basename "$file") — $section (missing section header)"
    return 1
  fi

  local content
  content=$(get_section_content "$file" "$section") || return 0

  local bare
  bare=$(echo "$content" | grep -v '^[[:space:]]*$' | head -1)
  [ -z "$bare" ] && return 0

  if ! section_has_skeleton "$content" "$skeleton_type"; then
    echo "  ❌ $(basename "$file") — $section (expected: $skeleton_type)"
    return 1
  fi

  # Check for unfilled TEMPLATE placeholders（内容还在用模板占位符）
  if has_placeholder_content "$content"; then
    echo "  ❌ $(basename "$file") — $section (unfilled placeholder)"
    return 1
  fi

  # Additional check: ℹ️ section must have **状态** line
  if [ "$section" = "ℹ️ 基本介绍" ]; then
    if ! echo "$content" | grep -q '\*\*状态\*\*'; then
      echo "  ❌ $(basename "$file") — $section (missing **状态**)"
      return 1
    fi
  fi
  return 0
}

# Validate frontmatter aliases: detect duplicate entries
# Obsidian UI renders duplicate aliases with strikethrough; raw markdown just has them duplicated.
# This catches the "soft-deleted but not removed" failure mode.
validate_aliases_unique() {
  local file="$1"
  # Extract aliases block from frontmatter
  local aliases_block
  aliases_block=$(awk '/^---$/{c++; next} c==1 && /^aliases:/{p=1; next} c==1 && p && /^[^[:space:]-]/{p=0} p' "$file")
  [ -z "$aliases_block" ] && return 0

  # Strip "- " prefix, strip ~~ strikethrough markers, trim whitespace
  local items
  items=$(echo "$aliases_block" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/~~//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Find duplicates (case-sensitive, exact match)
  local dups
  dups=$(echo "$items" | grep -v '^$' | sort | uniq -d)
  if [ -n "$dups" ]; then
    while IFS= read -r dup; do
      [ -z "$dup" ] && continue
      echo "  ❌ $(basename "$file") — aliases 重复项: $dup"
    done <<< "$dups"
    return 1
  fi
  return 0
}

# Validate frontmatter: aliases uniqueness + (future) other frontmatter checks
# Call this from validate-format.sh after section validation
validate_frontmatter() {
  local file="$1"
  validate_aliases_unique "$file"
}

# Parse GitHub Star value to numeric for sorting
# Examples: 100K → 100000, 8.4K → 8400, 233.7K → 233700, ~2K → 2000, 70K+ → 70000, 183 → 183, N/A → -1
parse_star_numeric() {
  local s="${1:-}"
  [ -z "$s" ] && { echo "-1"; return; }
  # 去掉前缀 ~ > < ≈ 和后缀 +（POSIX 写法，兼容 BSD sed）
  s=$(echo "$s" | sed 's/^[~><≈ 	]*//' | sed 's/[ 	]*$//' | sed 's/\+$//')
  # NK 格式
  if echo "$s" | grep -qE '^[0-9.]+K$'; then
    local num
    num=$(echo "$s" | sed 's/K$//')
    awk "BEGIN { printf \"%.0f\", $num * 1000 }"
    return
  fi
  # 纯数字
  if echo "$s" | grep -qE '^[0-9.]+$'; then
    echo "$s" | awk '{ printf "%.0f", $1 }'
    return
  fi
  # 无法解析（N/A、无（内部管理工具）等）→ -1 排最后
  echo "-1"
}

# Validate directory sorting: files must be NN-numbered in GitHub Star descending order
# N/A sorts last; ties broken by filename ascending
validate_directory_sorting() {
  local dir="$1"
  [ ! -d "$dir" ] && return 0

  local files
  files=$(find "$dir" -maxdepth 1 -name '[0-9][0-9]-*.md' -type f 2>/dev/null | sort)
  local count
  count=$(echo "$files" | grep -c .)
  [ "$count" -lt 2 ] && return 0

  # Build (nn, filename, star_numeric) tuples
  local entries=""
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    local fn star_raw star_num
    fn=$(basename "$f")
    star_raw=$(grep -m1 '^GitHub Star:' "$f" | sed 's/^GitHub Star:[[:space:]]*//')
    star_num=$(parse_star_numeric "$star_raw")
    entries="${entries}${star_num}|${fn}
"
  done <<< "$files"

  # Compute expected order: star desc, filename asc
  local expected current
  expected=$(printf '%s' "$entries" | grep -v '^$' | sort -t'|' -k1,1nr -k2,2 | cut -d'|' -f2)
  current=$(printf '%s' "$entries" | grep -v '^$' | sort -t'|' -k2,2 | cut -d'|' -f2)

  if [ "$expected" != "$current" ]; then
    echo "  ❌ 目录 $(basename "$dir")/ — 文件未按 GitHub Star 降序排列"
    return 1
  fi
  return 0
}

# Detect if section content is still using TEMPLATE placeholder text
# TEMPLATE.md 里的占位符标记文本只该出现在模板里，出现在实际文档说明段还是模板状态
# 命中即返回 0（true = 是 placeholder），不命中返回 1（false = 已填真实内容）
has_placeholder_content() {
  local content="$1"
  # 常见占位符：依赖项名称 / 具体描述 / 对应的解决方案 / 详细描述第N行 / 功能名+简短说明 / 安装命令（brew
  if echo "$content" | grep -qE '依赖项名称|具体描述|对应的解决方案|详细描述(第一|第二)行|安装命令（brew'; then
    return 0
  fi
  # 🧩 核心功能 的 details 标题里含"功能名：简短说明"
  if echo "$content" | grep -qE '<b>功能名</b>.*简短说明|简短说明</summary>'; then
    return 0
  fi
  return 1
}

# Normalize section name: strip emoji prefix, keep only the Chinese part after space
# 例如 "ℹ️ 基本介绍" → "基本介绍"（避免 NFC/NFD 规范化差异）
_normalize_sec() {
  echo "$1" | sed 's/^[^[:space:]]*[[:space:]]*//' | sed 's/^[[:space:]]*//'
}

# Validate section order + presence + non-standard sections
# 文件实际段必须严格匹配 TEMPLATE 的 9 段（顺序 + 内容），不能多、不能少、不能换序
# 使用"去 emoji 前缀后的中文名"比对，规避 emoji 规范化问题
validate_section_structure() {
  local file="$1"
  local expected expected_names
  expected=$(get_template_sections)
  # 期望的规范段名列表（去 emoji）；用 here-doc 避免管道子 shell 变量丢失
  expected_names=""
  while IFS= read -r s; do
    [ -z "$s" ] && continue
    expected_names="${expected_names}$(_normalize_sec "$s")
"
  done <<< "$expected"

  local actual actual_names
  actual=$(grep "^## " "$file" 2>/dev/null | sed 's/^## //')
  # 实际的规范段名列表
  actual_names=""
  while IFS= read -r s; do
    [ -z "$s" ] && continue
    actual_names="${actual_names}$(_normalize_sec "$s")
"
  done <<< "$actual"

  local has_error=0
  # 非标准段：actual 中有但 expected_names 中没有的（按规范名比对）
  while IFS= read -r sec; do
    [ -z "$sec" ] && continue
    local sec_name
    sec_name=$(_normalize_sec "$sec")
    if ! echo "$expected_names" | grep -qxF "$sec_name"; then
      echo "  ❌ $(basename "$file") — 非标准段: $sec"
      has_error=1
    fi
  done <<< "$actual"

  # 缺失段：expected 中有但 actual 中没有的
  while IFS= read -r sec; do
    [ -z "$sec" ] && continue
    local sec_name
    sec_name=$(_normalize_sec "$sec")
    if ! echo "$actual_names" | grep -qxF "$sec_name"; then
      echo "  ❌ $(basename "$file") — 缺失段: $sec"
      has_error=1
    fi
  done <<< "$expected"

  # 顺序：actual 里属于标准的段按出现顺序排列，和 expected 比对
  local actual_filtered=""
  while IFS= read -r sec; do
    [ -z "$sec" ] && continue
    local sec_name
    sec_name=$(_normalize_sec "$sec")
    if echo "$expected_names" | grep -qxF "$sec_name"; then
      actual_filtered="${actual_filtered}${sec_name}
"
    fi
  done <<< "$actual"

  if [ "$actual_filtered" != "$expected_names" ]; then
    echo "  ❌ $(basename "$file") — 段顺序错误（应按 TEMPLATE: ℹ️→🎯→📦→💿→💊→🧩→⌨️→⚠️→📝）"
    has_error=1
  fi
  return $has_error
}

# Detect commented-out URLs in callout code blocks
# 形如 "> # https://..." / "> # GitHub: https://..." / "> # 3. 粘贴 https://..." 都算
# 任何 "> #" 开头且行内含 URL 的行都算把 URL 藏在注释里
# URL 应该可直接选中（去掉 # 前缀，或移到 callout 外做 markdown 链接）
validate_no_commented_urls() {
  local file="$1"
  local hits
  # 匹配 > # 开头且行内含 http:// 或 https:// 的（URL 不必紧跟 #）
  hits=$(grep -nE '^>[[:space:]]*#.*https?://' "$file" 2>/dev/null)
  if [ -n "$hits" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      local ln content
      ln=$(echo "$line" | cut -d: -f1)
      content=$(echo "$line" | cut -d: -f2- | sed 's/^[[:space:]]*//')
      echo "  ❌ $(basename "$file"):${ln} — URL 被注释隐藏: ${content:0:70}"
    done <<< "$hits"
    return 1
  fi
  return 0
}

# Detect duplicate adjacent --- horizontal rules
# TEMPLATE 规定 frontmatter 后可以有一对相邻 ---（frontmatter 结束 + 文档主体分隔），合法
# 其他位置的相邻 ---（中间最多 1 空行）都是冗余分隔符
# 文件尾部双 ---（段尾分隔 + 文件结束符）也算
validate_no_duplicate_hr() {
  local file="$1"
  # 提取所有 --- 行的行号
  local hr_lines
  hr_lines=$(grep -nE '^---[[:space:]]*$' "$file" 2>/dev/null | cut -d: -f1)
  [ -z "$hr_lines" ] && return 0

  # 跳过前两个 ---（frontmatter 开始 + 结束）
  local fm_end=""
  local count=0
  local filtered=""
  while IFS= read -r ln; do
    [ -z "$ln" ] && continue
    count=$((count + 1))
    if [ "$count" -le 2 ]; then
      fm_end="$ln"
      continue
    fi
    filtered="${filtered}${ln}
"
  done <<< "$hr_lines"

  [ -z "$filtered" ] && return 0

  # 检查 frontmatter 结束 --- 后是否紧跟另一个 ---（TEMPLATE 标准：合法）
  # 这种情况第一个 --- 是 fm_end，第二个是 filtered 第一行
  local first_after_fm
  first_after_fm=$(echo "$filtered" | head -1)
  if [ -n "$fm_end" ] && [ -n "$first_after_fm" ]; then
    # 如果 first_after_fm 与 fm_end 之间只有空行，视为合法的 frontmatter 后分隔
    local between
    between=$(sed -n "$((fm_end+1)),$((first_after_fm-1))p" "$file" | grep -c '^$')
    local total_lines
    total_lines=$((first_after_fm - fm_end - 1))
    if [ "$between" = "$total_lines" ]; then
      # 整段都是空行 → TEMPLATE 标准的 frontmatter 后分隔，跳过 first_after_fm
      filtered=$(echo "$filtered" | tail -n +2)
    fi
  fi

  [ -z "$filtered" ] && return 0

  # 剩下的 --- 检查相邻性（中间最多 1 空行）
  local prev=""
  local has_error=0
  while IFS= read -r ln; do
    [ -z "$ln" ] && continue
    if [ -n "$prev" ]; then
      local between
      between=$(sed -n "$((prev+1)),$((ln-1))p" "$file" | grep -c '^$')
      local total_lines
      total_lines=$((ln - prev - 1))
      # 全是空行且距离 ≤ 2 → 相邻双 ---
      if [ "$between" = "$total_lines" ] && [ "$total_lines" -le 2 ]; then
        echo "  ❌ $(basename "$file"):${prev}-${ln} — 冗余双 ---（中间无内容）"
        has_error=1
      fi
    fi
    prev="$ln"
  done <<< "$filtered"
  return $has_error
}

# Detect commented-out commands in callout code blocks
# 形如 "> # /skill xxx" / "> # $ xxx" / "> # npm xxx" — 命令被注释隐藏
# 区别于说明性注释（"# npm 安装"、"# 方式 1"、"# 参考"）——这些末尾无参数
# 判别规则：# 后是斜杠命令（/xxx）或可执行命令 + 参数
validate_no_commented_commands() {
  local file="$1"
  # 匹配 > # 后紧跟斜杠（/command 形式，如 /skill /chat /help）
  local hits
  hits=$(grep -nE '^>[[:space:]]*#[[:space:]]*/[a-zA-Z]' "$file" 2>/dev/null)
  if [ -n "$hits" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      local ln content
      ln=$(echo "$line" | cut -d: -f1)
      content=$(echo "$line" | cut -d: -f2- | sed 's/^[[:space:]]*//')
      echo "  ❌ $(basename "$file"):${ln} — 命令被注释隐藏: ${content:0:70}"
    done <<< "$hits"
    return 1
  fi
  return 0
}
