param(
    [Parameter(Mandatory=$true)]
    [string]$RepoPath
)

if (-not (Test-Path $RepoPath)) {
    Write-Error "Directory not found: $RepoPath"
    exit 1
}

$repoName = Split-Path $RepoPath -Leaf

Set-Location $RepoPath

try {
    $gitCheck = git rev-parse --is-inside-work-tree 2>$null
    if (-not $gitCheck) {
        Write-Error "Not a git repository: $RepoPath"
        exit 1
    }
} catch {
    Write-Error "Not a git repository: $RepoPath"
    exit 1
}

$branch = git rev-parse --abbrev-ref HEAD

$status = git status --porcelain
if (-not $status) {
    Write-Host "No changes to commit" -ForegroundColor Yellow
    exit 0
}

Write-Host "`nChanges to be committed:" -ForegroundColor Cyan
git status -s

$commitMessage = "Update"

Write-Host "`nAbout to commit and push to '$repoName' repository (branch: $branch)" -ForegroundColor Cyan
Write-Host "Commit message: $commitMessage" -ForegroundColor White

$confirm = Read-Host "`nContinue? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Aborted by user" -ForegroundColor Yellow
    exit
}

git add .
git commit -m $commitMessage
git push origin $branch

Write-Host "`nCommit and push complete" -ForegroundColor Green