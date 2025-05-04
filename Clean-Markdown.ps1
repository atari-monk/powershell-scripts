param (
    [string]$InputFile,
    [string]$OutputFile
)

if (-not $InputFile -or -not $OutputFile) {
    Write-Host "Usage: .\Clean-Markdown.ps1 -InputFile <input.md> -OutputFile <output.txt>"
    exit 1
}

if (-not (Test-Path -Path $InputFile)) {
    Write-Host "Input file not found: $InputFile"
    exit 1
}

$content = Get-Content -Path $InputFile -Raw

$plainText = $content -replace '(?m)^#+\s*', '' `
    -replace '(?m)^\s*[-*+]\s*', '' `
    -replace '(?m)^\s*\d+\.\s*', '' `
    -replace '\*\*|__', '' `
    -replace '\*|_', '' `
    -replace '`', '' `
    -replace '\[([^\]]+)\]\([^\)]+\)', '$1' `
    -replace '(?m)^>\s*', '' `
    -replace '(?m)\s{2,}', "`r`n" `
    -replace '(?m)^\s+', '' `
    -replace '(?m)\s+$', ''

$plainText.Trim() | Out-File -FilePath $OutputFile -Encoding utf8