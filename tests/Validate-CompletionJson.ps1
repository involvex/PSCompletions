<#
.SYNOPSIS
    Validates PSCompletions JSON files for syntax and structure.

.DESCRIPTION
    This script validates completion JSON files (en-US.json, zh-CN.json) to ensure:
    - Valid JSON syntax
    - Required fields are present
    - Correct data types
    - No duplicate command names
    - Proper option structure

.PARAMETER CompletionPath
    Path to the completion directory to validate.

.EXAMPLE
    .\Validate-CompletionJson.ps1 -CompletionPath "D:\repos\PSCompletions\completions\pyenv"

.EXAMPLE
    .\Validate-CompletionJson.ps1 -CompletionPath ".\completions\pyenv"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CompletionPath
)

$ErrorCount = 0
$WarningCount = 0

Write-Host "Validating completion JSON files in: $CompletionPath" -ForegroundColor Cyan
Write-Host ""

# Check if completion directory exists
if (-not (Test-Path -Path $CompletionPath)) {
    Write-Host "❌ Error: Completion directory not found: $CompletionPath" -ForegroundColor Red
    exit 1
}

# Get all JSON files in the language directory
$languagePath = Join-Path -Path $CompletionPath -ChildPath "language"
$jsonFiles = Get-ChildItem -Path $languagePath -Filter "*.json" -ErrorAction SilentlyContinue

if ($null -eq $jsonFiles -or $jsonFiles.Count -eq 0) {
    Write-Host "❌ Error: No JSON files found in $languagePath" -ForegroundColor Red
    exit 1
}

foreach ($jsonFile in $jsonFiles) {
    Write-Host "Validating: $($jsonFile.Name)" -ForegroundColor Yellow
    
    try {
        # Read and parse JSON
        $jsonContent = Get-Content -Path $jsonFile.FullName -Raw | ConvertFrom-Json
        
        # Check required fields
        $requiredFields = @('meta', 'root', 'option', 'common_option')
        foreach ($field in $requiredFields) {
            if (-not ($jsonContent.PSObject.Properties.Name -contains $field)) {
                Write-Host "  ❌ Missing required field: $field" -ForegroundColor Red
                $ErrorCount++
            }
        }
        
        # Validate meta field
        if ($jsonContent.PSObject.Properties.Name -contains 'meta') {
            if (-not ($jsonContent.meta.PSObject.Properties.Name -contains 'url')) {
                Write-Host "  ⚠️  Warning: meta.url is missing" -ForegroundColor Yellow
                $WarningCount++
            }
            if (-not ($jsonContent.meta.PSObject.Properties.Name -contains 'description')) {
                Write-Host "  ⚠️  Warning: meta.description is missing" -ForegroundColor Yellow
                $WarningCount++
            }
        }
        
        # Validate root commands
        if ($jsonContent.PSObject.Properties.Name -contains 'root') {
            $commandNames = @()
            foreach ($command in $jsonContent.root) {
                if (-not ($command.PSObject.Properties.Name -contains 'name')) {
                    Write-Host "  ❌ Error: Command missing 'name' field" -ForegroundColor Red
                    $ErrorCount++
                    continue
                }
                
                # Check for duplicate command names
                if ($commandNames -contains $command.name) {
                    Write-Host "  ❌ Error: Duplicate command name: $($command.name)" -ForegroundColor Red
                    $ErrorCount++
                }
                $commandNames += $command.name
                
                # Validate tip field
                if (-not ($command.PSObject.Properties.Name -contains 'tip')) {
                    Write-Host "  ⚠️  Warning: Command '$($command.name)' missing 'tip' field" -ForegroundColor Yellow
                    $WarningCount++
                }
                
                # Validate options if present
                if ($command.PSObject.Properties.Name -contains 'option') {
                    foreach ($option in $command.option) {
                        if (-not ($option.PSObject.Properties.Name -contains 'name')) {
                            Write-Host "  ❌ Error: Option in command '$($command.name)' missing 'name' field" -ForegroundColor Red
                            $ErrorCount++
                        }
                    }
                }
            }
            
            Write-Host "  ✓ Found $($commandNames.Count) commands" -ForegroundColor Green
        }
        
        # Validate global options
        if ($jsonContent.PSObject.Properties.Name -contains 'option') {
            foreach ($option in $jsonContent.option) {
                if (-not ($option.PSObject.Properties.Name -contains 'name')) {
                    Write-Host "  ❌ Error: Global option missing 'name' field" -ForegroundColor Red
                    $ErrorCount++
                }
            }
            Write-Host "  ✓ Found $($jsonContent.option.Count) global options" -ForegroundColor Green
        }
        
        # Validate common options
        if ($jsonContent.PSObject.Properties.Name -contains 'common_option') {
            foreach ($option in $jsonContent.common_option) {
                if (-not ($option.PSObject.Properties.Name -contains 'name')) {
                    Write-Host "  ❌ Error: Common option missing 'name' field" -ForegroundColor Red
                    $ErrorCount++
                }
            }
            Write-Host "  ✓ Found $($jsonContent.common_option.Count) common options" -ForegroundColor Green
        }
        
        Write-Host "  ✓ JSON syntax is valid" -ForegroundColor Green
        
    } catch {
        Write-Host "  ❌ Error: Invalid JSON syntax - $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    }
    
    Write-Host ""
}

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