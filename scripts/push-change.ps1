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

# Snapshot the local changes as a stash commit without touching the working tree.
$stash = git stash create "push-change: $message"
if ($LASTEXITCODE -ne 0 -or -not $stash) {
    throw 'Could not capture the local changes as a stash.'
}

# The remote may move between checkout and push, so an attempt that loses the race is discarded and replayed onto the new tip.
$retryDelay = 15
$maxAttempts = 10
$pushed = $false
for ($i = 0; $i -lt $maxAttempts; $i++) {
    if ($i -gt 0) {
        Write-Warning "Retrying in $retryDelay seconds..."
        Start-Sleep -Seconds $retryDelay
    }

    Write-Host 'Resetting to the latest remote state...' -ForegroundColor Cyan
    git fetch origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Fetch failed.'
        continue
    }
    git reset --hard FETCH_HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Reset failed.'
        continue
    }

    Write-Host 'Applying local changes...' -ForegroundColor Cyan
    git stash apply $stash
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Applying the local changes failed, discarding the partial result.'
        git reset --hard FETCH_HEAD | Out-Null
        continue
    }

    git -c core.safecrlf=false add -u
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'No changes left to push.' -ForegroundColor Green
        $pushed = $true
        break
    }

    git -c user.name="$author" -c user.email="$email" commit --no-gpg-sign -m "$message"
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Commit failed.'
        continue
    }

    Write-Host 'Pushing updates ...' -ForegroundColor Cyan
    git push origin $branch
    if ($LASTEXITCODE -ne 0) {
        Write-Warning 'Push failed.'
        continue
    }
    $pushed = $true
    break
}

if (-not $pushed) {
    throw "Failed to push '$branch' after $maxAttempts attempts."
}
