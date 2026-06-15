# File Handling Rules

当用户要求读取或处理以下格式的文件时，必须使用 `markitdown` MCP 工具的 `convert_to_markdown` 方法：
- PDF (.pdf)
- Word (.docx)
- PowerPoint (.pptx)
- Excel (.xlsx)
- Images (.png, .jpg, .jpeg, .gif)
- Audio (.mp3, .wav)
- HTML (.html)
- CSV / JSON / XML
- 其他无法直接读取的二进制格式

调用方式：`convert_to_markdown(file:///path/to/file)`
