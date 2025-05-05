# Clean Markdown

## Function
Converts Markdown file to plain text by removing formatting elements (headers, lists, emphasis, links, etc.) and outputs clean text.

## Parameters
- `$InputFile`: (string) Path to source Markdown (.md) file
- `$OutputFile`: (string) Path for output plain text file

## Processing Logic
1. Validates input parameters and file existence
2. Removes:
   - Headers (`#`, `##`, etc.)
   - List markers (`-`, `*`, `+`, `1.`)
   - Emphasis (`**bold**`, `_italic_`, `__underline__`)
   - Code marks (`` ` ``)
   - Links (`[text](url)`)
   - Blockquotes (`>`)
3. Normalizes whitespace (converts multiple spaces to newlines, trims lines)
4. Outputs UTF-8 encoded text file

## Usage Examples
```powershell
# Basic conversion
.\Clean-Markdown.ps1 -InputFile "notes.md" -OutputFile "clean.txt"

# With path variables
$in = "C:\docs\input.md"
$out = "C:\output\clean.txt"
.\Clean-Markdown.ps1 -InputFile $in -OutputFile $out
```

## Error Handling
- Exits with code 1 if:
  - Parameters are missing
  - Input file doesn't exist