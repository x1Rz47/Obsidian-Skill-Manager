# -*- coding: utf-8 -*-
"""知识库文档 schema — TEMPLATE.md 的正式定义
单一真相源：validate_schema.py 按 schema 严格校验
修改本文件 = 修改所有文档的校验标准
"""

# 文档必须的 frontmatter 字段（顺序敏感）
FRONTMATTER_ORDER = [
    "aliases", "类型", "GitHub 链接", "GitHub Star",
    "使用设备", "使用平台", "创建日期", "更新日期", "必用"
]

# 段顺序（严格）
SECTION_ORDER = [
    "ℹ️ 基本介绍", "🎯 使用场景", "📦 前置依赖", "💿 安装",
    "💊 痛点解决", "🧩 核心功能", "⌨️ 使用方法", "⚠️ 注意事项", "📝 更新功能"
]

# 每段的结构约束
SECTIONS = {
    "ℹ️ 基本介绍": {"skeleton": "abstract_callout", "must_contain": ["**状态**"]},
    "🎯 使用场景": {"skeleton": "plain_list", "min_items": 1},
    "📦 前置依赖": {"skeleton": "prereq_list", "min_items": 1},
    "💿 安装": {"skeleton": "info_callout", "must_contain_code_block": True},
    "💊 痛点解决": {"skeleton": "table_header", "min_rows": 1},
    "🧩 核心功能": {"skeleton": "details_blocks", "min_blocks": 1},
    "⌨️ 使用方法": {"skeleton": "info_callout"},
    "⚠️ 注意事项": {"skeleton": "warning_callout"},
    "📝 更新功能": {"skeleton": "plain_list", "min_items": 1},
}

# 全局禁止模式（任何位置都不允许）
FORBIDDEN_PATTERNS = [
    (r'^>[ \t]*#.*https?://', "URL 被注释隐藏"),
    (r'^>[ \t]*#[ \t]*/[a-zA-Z]', "斜杠命令被注释隐藏"),
    (r'^[ \t]*-+<[ \t]*(table|thead|tbody|tr|td|th|div|section|article|details)\b', "HTML 块被错误包成 list"),
    (r'依赖项名称|具体描述|对应的解决方案|详细描述第[一二]行|<b>功能名</b>.*简短说明|安装命令（brew', "TEMPLATE 占位符未替换"),
    (r'^>[ \t]*\[!quote\]', "🧩 段必须用 <details>，不接受 > [!quote]"),
]

# 跨段结构禁止
FORBIDDEN_STRUCTURES = {
    "duplicate_hr": True,        # 文件尾部双 ---（除 frontmatter 后那对）
    "aliases_unique": True,      # aliases 重复项
    "section_strict_order": True, # 段顺序严格
}

# TEMPLATE 占位符文本（用于检测未填充段）
PLACEHOLDER_TEXTS = [
    "依赖项名称", "具体描述", "对应的解决方案",
    "详细描述第一行", "详细描述第二行",
    "功能名", "简短说明", "安装命令（brew",
]
