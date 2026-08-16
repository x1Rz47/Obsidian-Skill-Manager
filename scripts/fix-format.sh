#!/bin/bash
# fix-format.sh — Auto-fix every 知识库 file's section format to match TEMPLATE.md
# Usage: ./fix-format.sh <vault_dir>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

VAULT="${1:-}"
if [ -z "$VAULT" ]; then
  echo "Usage: $0 <vault_path>"
  echo "Example: $0 ~/path/to/04.AI相关-🤖/01.辅助工具"
  exit 1
fi

if [ ! -d "$VAULT" ]; then
  echo "Error: directory not found: $VAULT"
  exit 1
fi

echo "=== Fix Format: $(basename "$VAULT") ==="
echo "Template: $TEMPLATE"
echo ""

total_files=0
fixed_files=0
total_fixes=0

while IFS= read -r file; do
  total_files=$((total_files + 1))
  file_fixes=0
  file_output=""

  # Ensure all template sections exist before fixing
  sec_output=$(ensure_template_sections "$file" 2>&1) || true
  if echo "$sec_output" | grep -q 'FIXED'; then
    file_output+="$sec_output"$'\n'
    file_fixes=$((file_fixes + 1))
  fi

  while IFS= read -r section; do
    output=$(fix_section_format "$file" "$section" 2>&1) || true
    if echo "$output" | grep -q 'FIXED'; then
      file_output+="$output"$'\n'
      file_fixes=$((file_fixes + 1))
    fi
  done < <(get_template_sections)

  if [ "$file_fixes" -gt 0 ]; then
    echo "$(basename "$file"):"
    echo "$file_output" | sed 's/^/  /'
    fixed_files=$((fixed_files + 1))
    total_fixes=$((total_fixes + file_fixes))
  fi
done < <(find "$VAULT" -name "*.md")

echo ""
echo "=== Summary ==="
echo "Total files scanned: $total_files"
echo "Files fixed: $fixed_files"
echo "Total fixes applied: $total_fixes"

if [ "$fixed_files" -eq 0 ]; then
  echo "All files already match TEMPLATE.md format ✅"
fi
