param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    
    [Parameter(Mandatory=$true)]
    [string]$Target,
    
    [switch]$Force
)

if (-not (Test-Path -Path $Source)) {
    Write-Error "Source path does not exist: $Source"
    exit 1
}

if (-not (Test-Path -Path $Target -PathType Container)) {
    try {
        New-Item -Path $Target -ItemType Directory -Force | Out-Null
        Write-Host "Created target directory: $Target" -ForegroundColor Cyan
    } catch {
        Write-Error "Failed to create target directory: $_"
        exit 1
    }
}

$item = Get-Item -Path $Source
$isFile = $item -is [System.IO.FileInfo]

try {
    if ($isFile) {
        $targetPath = Join-Path -Path $Target -ChildPath $item.Name
        
        if (Test-Path -Path $targetPath) {
            if ($Force) {
                Remove-Item -Path $targetPath -Force
            } else {
                $choice = Read-Host "Target file exists. Overwrite? [Y/N]"
                if ($choice -ne 'Y') {
                    Write-Host "Operation cancelled." -ForegroundColor Yellow
                    exit 0
                }
            }
        }
        
        Write-Progress -Activity "Moving file" -Status $item.Name
        Move-Item -Path $Source -Destination $Target -Force:$Force
    } else {
        $targetPath = Join-Path -Path $Target -ChildPath $item.Name
        
        if (Test-Path -Path $targetPath) {
            if (-not $Force) {
                $choice = Read-Host "Target folder exists. Merge contents? [Y/N]"
                if ($choice -ne 'Y') {
                    Write-Host "Operation cancelled." -ForegroundColor Yellow
                    exit 0
                }
            }
        }
        
        Write-Progress -Activity "Moving directory" -Status $item.Name
        Get-ChildItem -Path $Source -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Substring($item.FullName.Length)
            $newPath = Join-Path -Path $targetPath -ChildPath $relativePath
            
            $parentDir = Split-Path -Path $newPath -Parent
            if (-not (Test-Path -Path $parentDir)) {
                New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
            }
            
            Move-Item -Path $_.FullName -Destination $newPath -Force:$Force
        }
        
        if ((Get-ChildItem -Path $Source -Force | Measure-Object).Count -eq 0) {
            Remove-Item -Path $Source -Force
        }
    }
    
    Write-Host "Move operation completed successfully!" -ForegroundColor Green
} catch {
    Write-Error "Error during move operation: $_"
    exit 1
}