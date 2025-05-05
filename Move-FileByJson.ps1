param(
    [string]$ConfigFile = "C:\atari-monk\code\apps-data-store\file_mappings.json"
)

if (-not (Test-Path -Path $ConfigFile)) {
    Write-Error "Config file not found: $ConfigFile"
    exit 1
}

try {
    $mappings = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON config file: $_"
    exit 1
}

foreach ($mapping in $mappings) {
    $source = $mapping.source
    $destination = $mapping.destination

    if (-not (Test-Path -Path $source)) {
        Write-Warning "Source path not found: $source"
        continue
    }

    if (-not (Test-Path -Path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
    }

    try {
        Write-Host "Copying from $source to $destination..."
        Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force
        Write-Host "Successfully copied files to $destination" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to copy files from $source to $destination: $_"
    }
}

Write-Host "File transfer completed" -ForegroundColor Cyan
