param (
    [Parameter(Mandatory=$true)]
    [string]$repo_name,
    
    [string]$code_path = "C:\atari-monk\code"
)

$current_path = Get-Location
$repo_path = Join-Path -Path $code_path -ChildPath $repo_name
cd $repo_path

$egg_info_path = Join-Path -Path $code_path -ChildPath "$repo_name\$repo_name.egg-info"

try {
    pip uninstall $repo_name -y
    Write-Host "Uninstalled package: $repo_name"
} catch {
    Write-Warning "Failed to uninstall $repo_name (may not be installed)"
}

if (Test-Path $egg_info_path) {
    try {
        Remove-Item -Path $egg_info_path -Recurse -Force
        Write-Host "Removed: $egg_info_path"
    } catch {
        Write-Error "Failed to remove $egg_info_path"
    }
} else {
    Write-Host "Directory does not exist: $egg_info_path"
}

try {
    pip install -e .
    Write-Host "Successfully installed $repo_name in development mode"
} catch {
    Write-Error "Failed to install $repo_name in development mode"
}

cd $current_path
exit 1