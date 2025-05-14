param(
    [Parameter(Mandatory=$true)]
    [string]$RepoPath
)

if (-not (Test-Path $RepoPath)) {
    Write-Error "Directory not found: $RepoPath"
    exit 1
}

$RepoName = Split-Path $RepoPath -Leaf

Write-Host "`nWARNING: THIS WILL DESTROY ALL GIT HISTORY!" -ForegroundColor Red -BackgroundColor Black
Write-Host "• Local history will be erased" -ForegroundColor Red
Write-Host "• Remote GitHub history will be overwritten" -ForegroundColor Red
$confirm = Read-Host "`nARE YOU SURE? (Type 'YES' to continue)"

if ($confirm -ne "YES") {
    Write-Host "Aborted by user" -ForegroundColor Yellow
    exit
}

Remove-Item -Recurse -Force "$RepoPath\.git" -ErrorAction SilentlyContinue
Set-Location $RepoPath
git init
git add .
git commit -m "Update"
git remote add origin "https://github.com/atari-monk/$RepoName.git"
git push -u --force origin master

Write-Host "`nRepository reset complete" -ForegroundColor Green