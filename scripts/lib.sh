#!/bin/bash
# lib.sh — Common functions for 知识库 template format operations
# Usage: source "$(dirname "$0")/lib.sh"

SKILL_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
TEMPLATE="$SKILL_DIR/TEMPLATE.md"

# Section → skeleton mapping (no emoji keys: use name suffix for lookup)
# Skeleton types: info_callout, warning_callout, abstract_callout, details_blocks, table_header
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
    head -n -1 "$file" > "${file}.tmp"
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
    plain_list)       echo "$effective" | grep -q '^- '                    ;;
    details_blocks)   echo "$content" | grep -qE '<details|> \[!quote\]'   ;;
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
      # Accept <details> or > [!quote] as valid format for 🧩
      if echo "$content" | grep -q '> \[!quote\]'; then
        # Already in quote format — fine, treat as valid
        true
      fi
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

  # Additional check: ℹ️ section must have **状态** line
  if [ "$section" = "ℹ️ 基本介绍" ]; then
    if ! echo "$content" | grep -q '\*\*状态\*\*'; then
      echo "  ❌ $(basename "$file") — $section (missing **状态**)"
      return 1
    fi
  fi
  return 0
}
