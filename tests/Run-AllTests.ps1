<#
.SYNOPSIS
    Runs all validation tests for PSCompletions completion packs.

.DESCRIPTION
    This script runs all validation tests for a completion pack:
    - Config validation
    - JSON validation
    - Hooks validation

.PARAMETER CompletionPath
    Path to the completion directory to validate.

.PARAMETER SkipConfig
    Skip config validation.

.PARAMETER SkipJson
    Skip JSON validation.

.PARAMETER SkipHooks
    Skip hooks validation.

.EXAMPLE
    .\Run-AllTests.ps1 -CompletionPath "D:\repos\PSCompletions\completions\pyenv"

.EXAMPLE
    .\Run-AllTests.ps1 -CompletionPath ".\completions\pyenv" -SkipHooks

.EXAMPLE
    .\Run-AllTests.ps1 -CompletionPath ".\completions\pyenv" -SkipConfig -SkipJson
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CompletionPath,
    
    [switch]$SkipConfig,
    [switch]$SkipJson,
    [switch]$SkipHooks
)

$ErrorCount = 0
$WarningCount = 0
$TestCount = 0
$PassedCount = 0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PSCompletions Test Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if completion directory exists
if (-not (Test-Path -Path $CompletionPath)) {
    Write-Host "❌ Error: Completion directory not found: $CompletionPath" -ForegroundColor Red
    exit 1
}

$completionName = Split-Path -Path $CompletionPath -Leaf
Write-Host "Testing completion: $completionName" -ForegroundColor Yellow
Write-Host "Path: $CompletionPath" -ForegroundColor Gray
Write-Host ""

# Run config validation
if (-not $SkipConfig) {
    $TestCount++
    Write-Host "[$TestCount] Running config validation..." -ForegroundColor Cyan
    $configResult = & "$PSScriptRoot\Validate-Config.ps1" -CompletionPath $CompletionPath
    if ($LASTEXITCODE -eq 0) {
        $PassedCount++
        Write-Host "✅ Config validation passed" -ForegroundColor Green
    } else {
        $ErrorCount++
        Write-Host "❌ Config validation failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Run JSON validation
if (-not $SkipJson) {
    $TestCount++
    Write-Host "[$TestCount] Running JSON validation..." -ForegroundColor Cyan
    $jsonResult = & "$PSScriptRoot\Validate-CompletionJson.ps1" -CompletionPath $CompletionPath
    if ($LASTEXITCODE -eq 0) {
        $PassedCount++
        Write-Host "✅ JSON validation passed" -ForegroundColor Green
    } else {
        $ErrorCount++
        Write-Host "❌ JSON validation failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Run hooks validation
if (-not $SkipHooks) {
    $TestCount++
    Write-Host "[$TestCount] Running hooks validation..." -ForegroundColor Cyan
    $hooksResult = & "$PSScriptRoot\Validate-Hooks.ps1" -CompletionPath $CompletionPath
    if ($LASTEXITCODE -eq 0) {
        $PassedCount++
        Write-Host "✅ Hooks validation passed" -ForegroundColor Green
    } else {
        $ErrorCount++
        Write-Host "❌ Hooks validation failed" -ForegroundColor Red
    }
    Write-Host ""
}

# Final summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total tests: $TestCount" -ForegroundColor White
Write-Host "Passed: $PassedCount" -ForegroundColor Green
Write-Host "Failed: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($ErrorCount -gt 0) {
    Write-Host "❌ Some tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All tests passed!" -ForegroundColor Green
    exit 0
}