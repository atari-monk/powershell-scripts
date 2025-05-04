param(
    [Parameter(Mandatory=$true)]
    [string]$folder,
    
    [Parameter(Mandatory=$true)]
    [string]$filter
)

$files = Get-ChildItem -Path $folder -Recurse -Filter "*$filter*" -File | Select-Object -ExpandProperty FullName

if ($files.Count -eq 1) {
    $files | Set-Clipboard
    Write-Host "Single file found and copied to clipboard:`n$files" -ForegroundColor Green
}
elseif ($files.Count -gt 1) {
    Write-Host "Multiple files found ($($files.Count)):" -ForegroundColor Yellow
    $files
}
else {
    Write-Host "No files found matching filter: *$filter*" -ForegroundColor Red
}