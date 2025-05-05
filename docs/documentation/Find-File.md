# Find File

## Function
Searches for files matching a filter in a specified folder (recursively) and:
- Copies single match to clipboard
- Lists multiple matches
- Reports if no matches found

## Parameters
- `folder` (Mandatory): Root directory path to search in
- `filter` (Mandatory): String pattern to match in filenames (wildcards automatically added)

## Usage Examples
```powershell
# Find single PDF file and copy path to clipboard
.\Find-File.ps1 -folder "C:\Documents" -filter "report.pdf"

# Find all text files in project directory
.\Find-File.ps1 -folder "D:\Projects" -filter ".txt"

# Search for invoices (handles multiple matches)
.\Find-File.ps1 -folder "E:\Accounting" -filter "invoice_2023"
```

## Output Behavior
- **1 match**: Copies full path to clipboard, shows success message (green)
- **>1 match**: Displays count (yellow) and lists all paths
- **0 matches**: Shows error message (red) with filter pattern