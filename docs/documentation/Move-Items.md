# Move Items

## Function
Moves files or directories from source to target location with safety checks and user prompts. Handles both files and directories recursively.

## Parameters
- `-Source` (Mandatory, string): Path to source file/directory to move
- `-Target` (Mandatory, string): Destination directory path
- `-Force` (Switch): Overwrite/merge without prompting

## Behavior
1. Validates source exists and target is a directory (creates if needed)
2. For files:
   - Prompts before overwrite (unless -Force)
   - Shows progress during move
3. For directories:
   - Prompts before merging (unless -Force)
   - Moves contents recursively
   - Creates parent directories as needed
4. Cleans up empty source directory after move

## Exit Codes
- 0: Success
- 1: Error (path invalid, operation failed)

## Examples
```powershell
# Move file (prompt if exists)
.\move.ps1 -Source "C:\data\file.txt" -Target "D:\backup"

# Force move directory (no prompts)
.\move.ps1 -Source "C:\logs" -Target "E:\archive" -Force
```

## Error Handling
- Catches and reports all move operations errors
- Validates paths before attempting operations