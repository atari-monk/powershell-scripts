# Install Local Module

## Function
Uninstalls an existing Python package, removes its egg-info directory, then reinstalls it in development mode. Handles common edge cases with error handling.

## Parameters
- `-repo_name` (Mandatory string): Name of the Python package/repository to reinstall
- `-code_path` (Optional string): Base directory containing the repository (default: "C:\atari-monk\code")

## Usage Examples
```powershell
# Basic usage
.\Install-LocalModule.ps1 -repo_name "my_package"

# Custom code path
.\Install-LocalModule.ps1 -repo_name "my_lib" -code_path "D:\dev\projects"
```

## Process Flow
1. Stores current working directory
2. Constructs full repository path
3. Attempts to uninstall existing package via pip
4. Removes egg-info directory if exists
5. Installs package in development mode (`-e .`)
6. Restores original working directory
7. Exits with status code 1 (non-zero indicates completion)

## Error Handling
- Gracefully handles cases where package isn't installed
- Provides warnings/errors for failed operations
- Skips non-existent egg-info directories