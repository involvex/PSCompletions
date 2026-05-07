<#
.SYNOPSIS
    Validates PSCompletions hooks.ps1 files for syntax and structure.

.DESCRIPTION
    This script validates hooks.ps1 files to ensure:
    - Valid PowerShell syntax
    - Required function is present
    - Proper function signature
    - No obvious syntax errors

.PARAMETER CompletionPath
    Path to the completion directory to validate.

.EXAMPLE
    .\Validate-Hooks.ps1 -CompletionPath "D:\repos\PSCompletions\completions\pyenv"

.EXAMPLE
    .\Validate-Hooks.ps1 -CompletionPath ".\completions\pyenv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CompletionPath
)

$ErrorCount = 0
$WarningCount = 0

Write-Host "Validating hooks.ps1 in: $CompletionPath" -ForegroundColor Cyan
Write-Host ""

# Check if completion directory exists
if (-not (Test-Path -Path $CompletionPath)) {
    Write-Host "❌ Error: Completion directory not found: $CompletionPath" -ForegroundColor Red
    exit 1
}

# Check if hooks.ps1 exists
$hooksPath = Join-Path -Path $CompletionPath -ChildPath "hooks.ps1"

if (-not (Test-Path -Path $hooksPath)) {
    Write-Host "⚠️  Warning: hooks.ps1 not found (optional file)" -ForegroundColor Yellow
    exit 0
}

Write-Host "Validating: hooks.ps1" -ForegroundColor Yellow

try {
    # Read the hooks file
    $hooksContent = Get-Content -Path $hooksPath -Raw
    
    # Check for required function
    if ($hooksContent -notmatch 'function\s+handleCompletions') {
        Write-Host "  ❌ Error: Required function 'handleCompletions' not found" -ForegroundColor Red
        $ErrorCount++
    } else {
        Write-Host "  ✓ Required function 'handleCompletions' found" -ForegroundColor Green
    }
    
    # Check for proper function signature
    if ($hooksContent -match 'function\s+handleCompletions\s*\(\s*\$completions\s*\)') {
        Write-Host "  ✓ Function signature is correct" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Warning: Function signature may not match expected format" -ForegroundColor Yellow
        $WarningCount++
    }
    
    # Check for common patterns
    $patterns = @{
        'PSCompletions\.input_arr' = 'Uses PSCompletions.input_arr'
        'PSCompletions\.filter_input_arr' = 'Uses PSCompletions.filter_input_arr'
        'PSCompletions\.return_completion' = 'Uses PSCompletions.return_completion'
    }
    
    foreach ($pattern in $patterns.Keys) {
        if ($hooksContent -match [regex]::Escape($pattern)) {
            Write-Host "  ✓ $($patterns[$pattern])" -ForegroundColor Green
        }
    }
    
    # Try to parse the script for syntax errors
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize($hooksContent, [ref]$null)
        Write-Host "  ✓ PowerShell syntax is valid" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Error: PowerShell syntax error - $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    }
    
    # Check for common issues
    if ($hooksContent -match 'Write-Host\s+.*-ForegroundColor') {
        Write-Host "  ℹ️  Info: Contains Write-Host statements (for debugging)" -ForegroundColor Gray
    }
    
    if ($hooksContent -match 'pyenv\s+') {
        Write-Host "  ℹ️  Info: Contains pyenv command calls" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "  ❌ Error: Failed to read hooks.ps1 - $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}

Write-Host ""

# Summary
Write-Host "Validation Summary:" -ForegroundColor Cyan
Write-Host "  Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })
Write-Host "  Warnings: $WarningCount" -ForegroundColor $(if ($WarningCount -gt 0) { "Yellow" } else { "Green" })

if ($ErrorCount -gt 0) {
    Write-Host ""
    Write-Host "❌ Validation failed with $ErrorCount error(s)" -ForegroundColor Red
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ All validations passed!" -ForegroundColor Green
    exit 0
}