<#
.SYNOPSIS
    Validates PSCompletions config.json files for syntax and structure.

.DESCRIPTION
    This script validates config.json files to ensure:
    - Valid JSON syntax
    - Required fields are present
    - Valid language codes
    - Proper hooks flag

.PARAMETER CompletionPath
    Path to the completion directory to validate.

.EXAMPLE
    .\Validate-Config.ps1 -CompletionPath "D:\repos\PSCompletions\completions\pyenv"

.EXAMPLE
    .\Validate-Config.ps1 -CompletionPath ".\completions\pyenv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CompletionPath
)

$ErrorCount = 0
$WarningCount = 0

Write-Host "Validating config.json in: $CompletionPath" -ForegroundColor Cyan
Write-Host ""

# Check if completion directory exists
if (-not (Test-Path -Path $CompletionPath)) {
    Write-Host "❌ Error: Completion directory not found: $CompletionPath" -ForegroundColor Red
    exit 1
}

# Check if config.json exists
$configPath = Join-Path -Path $CompletionPath -ChildPath "config.json"

if (-not (Test-Path -Path $configPath)) {
    Write-Host "❌ Error: config.json not found" -ForegroundColor Red
    exit 1
}

Write-Host "Validating: config.json" -ForegroundColor Yellow

try {
    # Read and parse JSON
    $configContent = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    
    # Check required fields
    $requiredFields = @('language')
    foreach ($field in $requiredFields) {
        if (-not ($configContent.PSObject.Properties.Name -contains $field)) {
            Write-Host "  ❌ Error: Missing required field: $field" -ForegroundColor Red
            $ErrorCount++
        }
    }
    
    # Validate language field
    if ($configContent.PSObject.Properties.Name -contains 'language') {
        if ($configContent.language -isnot [array]) {
            Write-Host "  ❌ Error: 'language' field must be an array" -ForegroundColor Red
            $ErrorCount++
        } else {
            Write-Host "  ✓ Found $($configContent.language.Count) language(s)" -ForegroundColor Green
            
            # Validate language codes
            $validLanguages = @('en-US', 'zh-CN', 'ja-JP', 'ko-KR', 'fr-FR', 'de-DE', 'es-ES')
            foreach ($lang in $configContent.language) {
                if ($lang -notin $validLanguages) {
                    Write-Host "  ⚠️  Warning: Unusual language code: $lang" -ForegroundColor Yellow
                    $WarningCount++
                }
            }
            
            # Check if en-US is present (recommended)
            if ('en-US' -notin $configContent.language) {
                Write-Host "  ⚠️  Warning: 'en-US' language not found (recommended)" -ForegroundColor Yellow
                $WarningCount++
            }
        }
    }
    
    # Validate hooks field
    if ($configContent.PSObject.Properties.Name -contains 'hooks') {
        if ($configContent.hooks -isnot [bool]) {
            Write-Host "  ❌ Error: 'hooks' field must be a boolean" -ForegroundColor Red
            $ErrorCount++
        } else {
            Write-Host "  ✓ Hooks flag: $($configContent.hooks)" -ForegroundColor Green
            
            # Check if hooks.ps1 exists when hooks is true
            if ($configContent.hooks) {
                $hooksPath = Join-Path -Path $CompletionPath -ChildPath "hooks.ps1"
                if (-not (Test-Path -Path $hooksPath)) {
                    Write-Host "  ⚠️  Warning: hooks flag is true but hooks.ps1 not found" -ForegroundColor Yellow
                    $WarningCount++
                } else {
                    Write-Host "  ✓ hooks.ps1 exists" -ForegroundColor Green
                }
            }
        }
    } else {
        Write-Host "  ℹ️  Info: 'hooks' field not found (defaults to false)" -ForegroundColor Gray
    }
    
    # Validate alias field (optional)
    if ($configContent.PSObject.Properties.Name -contains 'alias') {
        if ($configContent.alias -isnot [array]) {
            Write-Host "  ❌ Error: 'alias' field must be an array" -ForegroundColor Red
            $ErrorCount++
        } else {
            Write-Host "  ✓ Found $($configContent.alias.Count) alias(es)" -ForegroundColor Green
        }
    }
    
    Write-Host "  ✓ JSON syntax is valid" -ForegroundColor Green
    
} catch {
    Write-Host "  ❌ Error: Invalid JSON syntax - $($_.Exception.Message)" -ForegroundColor Red
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