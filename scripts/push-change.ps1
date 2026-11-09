#!/usr/bin/env pwsh
#Requires -Version 7.6.5

param(
    [string]$branch = 'main',
    [string]$author = 'github-actions[bot]',
    [string]$email = '41898282+github-actions[bot]@users.noreply.github.com',
    [string]$message = 'chore: automatically update some content'
)

git -c core.safecrlf=false add -u
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'No changes to commit.' -ForegroundColor Green
    return
}

git -c user.name="$author" -c user.email="$email" commit --no-gpg-sign -m "$message"

# Push
$retryDelay = 15
$maxAttempts = 10
$pushed = $false
for ($i = 0; $i -lt $maxAttempts; $i++) {
    Write-Host 'Pushing updates...' -ForegroundColor Cyan
    git push origin $branch
    if ($LASTEXITCODE -eq 0) {
        $pushed = $true
        break
    }
    Write-Warning 'Push failed, rebasing onto the remote tip.'
    git pull --rebase origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Pull failed, aborting the rebase to restore a clean state.'
        git rebase --abort *> $null
    }
    if ($i -lt $maxAttempts - 1) {
        Write-Warning "Retrying in $retryDelay seconds..."
        Start-Sleep -Seconds $retryDelay
    }
}

if (-not $pushed) {
    throw "Failed to push '$branch' after $maxAttempts attempts."
}
