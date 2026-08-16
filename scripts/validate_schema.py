#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Schema 驱动的文档校验器（单一入口，替代 8 个独立检测函数）
用法：python3 validate_schema.py <vault_dir>
"""
import os, re, sys, unicodedata
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from schema import (
    FRONTMATTER_ORDER, SECTION_ORDER, SECTIONS,
    FORBIDDEN_PATTERNS, FORBIDDEN_STRUCTURES
)

def norm(s):
    return unicodedata.normalize('NFC', s)

def get_frontmatter(text):
    m = re.match(r'^---\n(.*?)\n---\n', text, re.DOTALL)
    return m.group(1) if m else None

def parse_fm_fields(fm):
    fields, cur_key, cur_lines = [], None, []
    for line in fm.split('\n'):
        m = re.match(r'^([^\s:][^:]*?):\s*(.*)$', line)
        if m and not line.startswith(' ') and not line.startswith('\t'):
            if cur_key:
                fields.append((cur_key, cur_lines))
            cur_key, cur_lines = m.group(1), [m.group(2)]
        else:
            if cur_key:
                cur_lines.append(line)
    if cur_key:
        fields.append((cur_key, cur_lines))
    return fields

def get_sections(text):
    sections, cur_name, cur_lines, in_body = [], None, [], False
    for line in text.split('\n'):
        m = re.match(r'^## (.+)$', line)
        if m:
            if cur_name is not None:
                sections.append((cur_name, '\n'.join(cur_lines)))
            cur_name, cur_lines, in_body = m.group(1), [], True
        elif in_body:
            cur_lines.append(line)
    if cur_name:
        sections.append((cur_name, '\n'.join(cur_lines)))
    return sections

def check_skeleton(content, skeleton_type):
    effective = next((l for l in content.split('\n') if l.strip()), '')
    if skeleton_type == "abstract_callout":
        if not re.match(r'^>\s*\[!abstract\]', effective):
            return False, "缺 > [!abstract]"
        return True, ""
    if skeleton_type == "info_callout":
        if not re.match(r'^>\s*\[!info\]', effective):
            return False, "缺 > [!info]"
        return True, ""
    if skeleton_type == "warning_callout":
        if not re.match(r'^>\s*\[!warning\]', effective):
            return False, "缺 > [!warning]"
        return True, ""
    if skeleton_type in ("plain_list", "prereq_list"):
        if not re.match(r'^-\s', effective):
            return False, "缺 - 开头的 list"
        if re.search(r'^[ \t]*-+<[ \t]*(table|thead|tbody|tr|td|th|div|section|article|details)\b', content, re.MULTILINE):
            return False, "HTML 块被包成 list"
        return True, ""
    if skeleton_type == "table_header":
        if '🔢' not in effective:
            return False, "缺 | 🔢 | 表格头"
        return True, ""
    if skeleton_type == "details_blocks":
        if '<details>' not in content:
            return False, "缺 <details>（不接受 > [!quote]）"
        return True, ""
    return True, ""

def check_file(fpath):
    errors = []
    fname = os.path.basename(fpath)
    with open(fpath, 'r', encoding='utf-8') as f:
        text = f.read()
    text = norm(text)

    # 1. frontmatter 存在
    fm = get_frontmatter(text)
    if fm is None:
        return [f"{fname}: 缺 frontmatter"]

    # 2. frontmatter 字段顺序 + 完整性
    fields = parse_fm_fields(fm)
    keys = [k for k, _ in fields]
    for k in FRONTMATTER_ORDER:
        if k not in keys:
            errors.append(f"{fname}: frontmatter 缺字段 {k}")
    present = [k for k in keys if k in FRONTMATTER_ORDER]
    expected = [k for k in FRONTMATTER_ORDER if k in present]
    if present != expected:
        errors.append(f"{fname}: frontmatter 字段顺序错")

    # 3. aliases 重复
    fdict = {k: blk for k, blk in fields}
    if FORBIDDEN_STRUCTURES.get('aliases_unique') and 'aliases' in fdict:
        items = [re.sub(r'^[ \t]+-[ \t]*', '', ln).strip() for ln in fdict['aliases'] if ln.strip()]
        clean = [re.sub(r'~~', '', it) for it in items]
        for x in set([c for c in clean if clean.count(c) > 1]):
            errors.append(f"{fname}: aliases 重复: {x}")

    # 4. 段顺序 + 完整性
    sections = get_sections(text)
    sec_names = [norm(n) for n, _ in sections]
    expected_sec = [norm(s) for s in SECTION_ORDER]
    for n in sec_names:
        if n not in expected_sec:
            errors.append(f"{fname}: 非标准段: {n}")
    for s in expected_sec:
        if s not in sec_names:
            errors.append(f"{fname}: 缺失段: {s}")
    filtered = [n for n in sec_names if n in expected_sec]
    if FORBIDDEN_STRUCTURES.get('section_strict_order') and filtered != expected_sec:
        errors.append(f"{fname}: 段顺序错")

    # 5. 每段骨架
    sec_dict = {norm(n): c for n, c in sections}
    for sec_name, content in sec_dict.items():
        if sec_name not in SECTIONS:
            continue
        c = SECTIONS[sec_name]
        bare = next((l for l in content.split('\n') if l.strip()), '')
        if not bare:
            errors.append(f"{fname}: 段「{sec_name}」空")
            continue
        skel = c.get('skeleton')
        if skel:
            ok, reason = check_skeleton(content, skel)
            if not ok:
                errors.append(f"{fname}: 段「{sec_name}」骨架错（{reason}）")
        for must in c.get('must_contain', []):
            if must not in content:
                errors.append(f"{fname}: 段「{sec_name}」缺「{must}」")
        if c.get('must_contain_code_block') and '```' not in content:
            errors.append(f"{fname}: 段「{sec_name}」缺代码块")

    # 6. 全局禁止模式
    for pat, reason in FORBIDDEN_PATTERNS:
        for m in re.finditer(pat, text, re.MULTILINE):
            line_no = text[:m.start()].count('\n') + 1
            errors.append(f"{fname}:{line_no}: {reason}")

    # 7. 双 ---
    if FORBIDDEN_STRUCTURES.get('duplicate_hr'):
        hr_lines = [i+1 for i, l in enumerate(text.split('\n')) if l.strip() == '---']
        if len(hr_lines) >= 2:
            remaining = hr_lines[2:]
            fm_end = hr_lines[1]
            if remaining and remaining[0] - fm_end <= 3:
                remaining = remaining[1:]
            for i in range(len(remaining) - 1):
                if remaining[i+1] - remaining[i] <= 3:
                    errors.append(f"{fname}:{remaining[i]}-{remaining[i+1]}: 冗余双 ---")
                    break

    return errors

def main():
    vault = sys.argv[1] if len(sys.argv) > 1 else '.'
    if not os.path.isdir(vault):
        print(f"Error: {vault} 不是目录"); sys.exit(1)
    total, errs = 0, 0
    for root, _, files in os.walk(vault):
        if '.sync-backup' in root:
            continue
        for fn in sorted(files):
            if not fn.endswith('.md'):
                continue
            total += 1
            for e in check_file(os.path.join(root, fn)):
                print(f"  ❌ {e}")
                errs += 1
    print()
    print(f"=== Schema Validate ===")
    print(f"Total files: {total}")
    print(f"Total errors: {errs}")
    if errs == 0:
        print("All files match schema ✅")
        sys.exit(0)
    sys.exit(1)

if __name__ == '__main__':
    main()
