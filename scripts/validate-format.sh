#!/bin/bash
# validate-format.sh — Check every 知识库 file's section format against TEMPLATE.md
# Usage: ./validate-format.sh <vault_dir>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

VAULT="${1:-}"
if [ -z "$VAULT" ]; then
  echo "Usage: $0 <vault_path>"
  echo "Example: $0 ~/path/to/04.AI相关-🤖/辅助工具"
  exit 1
fi

if [ ! -d "$VAULT" ]; then
  echo "Error: directory not found: $VAULT"
  exit 1
fi

echo "=== Validate Format: $(basename "$VAULT") ==="
echo "Template: $TEMPLATE"
echo ""

total_files=0
total_errors=0
declare -a error_files

while IFS= read -r file; do
  fname=$(basename "$file")
  total_files=$((total_files + 1))

  file_errors=0
  # Validate section structure first: order + non-standard sections + missing
  struct_output=$(validate_section_structure "$file" 2>&1) || true
  if echo "$struct_output" | grep -q '❌'; then
    echo "$struct_output"
    file_errors=$((file_errors + 1))
  fi
  while IFS= read -r section; do
    output=$(validate_section_format "$file" "$section" 2>&1) || true
    if echo "$output" | grep -q '❌'; then
      echo "$output"
      file_errors=$((file_errors + 1))
    fi
  done < <(get_template_sections)

  # Validate frontmatter (aliases uniqueness, etc.)
  fm_output=$(validate_frontmatter "$file" 2>&1) || true
  if echo "$fm_output" | grep -q '❌'; then
    echo "$fm_output"
    file_errors=$((file_errors + 1))
  fi

  # Validate no commented-out URLs hiding in callout code blocks
  url_output=$(validate_no_commented_urls "$file" 2>&1) || true
  if echo "$url_output" | grep -q '❌'; then
    echo "$url_output"
    file_errors=$((file_errors + 1))
  fi

  # Validate no commented-out slash commands (e.g. /skill xxx) in callout code blocks
  cmd_output=$(validate_no_commented_commands "$file" 2>&1) || true
  if echo "$cmd_output" | grep -q '❌'; then
    echo "$cmd_output"
    file_errors=$((file_errors + 1))
  fi

  # Validate no duplicate adjacent --- horizontal rules (except frontmatter post-separator)
  hr_output=$(validate_no_duplicate_hr "$file" 2>&1) || true
  if echo "$hr_output" | grep -q '❌'; then
    echo "$hr_output"
    file_errors=$((file_errors + 1))
  fi

  if [ "$file_errors" -gt 0 ]; then
    total_errors=$((total_errors + 1))
    error_files+=("$(basename "$file") ($file_errors)")
  fi
done < <(find "$VAULT" -name "*.md")

# Validate directory sorting: every directory's files must be NN-numbered in GitHub Star descending order
sort_errors=0
while IFS= read -r d; do
  [ -z "$d" ] && continue
  output=$(validate_directory_sorting "$d" 2>&1) || true
  if echo "$output" | grep -q '❌'; then
    echo "$output"
    sort_errors=$((sort_errors + 1))
  fi
done < <(find "$VAULT" -type d)

echo ""
echo "=== Results ==="
echo "Total files: $total_files"
echo "Files with errors: $total_errors"
echo "Directories with sorting errors: $sort_errors"

if [ "$total_errors" -eq 0 ] && [ "$sort_errors" -eq 0 ]; then
  echo "All files match TEMPLATE.md format ✅"
  exit 0
else
  echo ""
  echo "Files needing fixes:"
  for f in "${error_files[@]}"; do
    echo "  - $f"
  done
  exit 1
fi
