# PSCompletions Test Framework

This directory contains automated tests for validating PSCompletions completion packs.

## Test Scripts

### Run-AllTests.ps1
Main test runner that executes all validation tests for a completion pack.

**Usage:**
```powershell
.\Run-AllTests.ps1 -CompletionPath "path\to\completion"
```

**Parameters:**
- `-CompletionPath` (required): Path to the completion directory
- `-SkipConfig`: Skip config validation
- `-SkipJson`: Skip JSON validation
- `-SkipHooks`: Skip hooks validation

**Examples:**
```powershell
# Test pyenv completion
.\Run-AllTests.ps1 -CompletionPath "D:\repos\PSCompletions\completions\pyenv"

# Test without hooks validation
.\Run-AllTests.ps1 -CompletionPath ".\completions\pyenv" -SkipHooks

# Test only config
.\Run-AllTests.ps1 -CompletionPath ".\completions\pyenv" -SkipJson -SkipHooks
```

### Validate-Config.ps1
Validates config.json files for syntax and structure.

**Checks:**
- Valid JSON syntax
- Required fields (language)
- Valid language codes
- Proper hooks flag
- Hooks.ps1 existence when hooks is true

**Usage:**
```powershell
.\Validate-Config.ps1 -CompletionPath "path\to\completion"
```

### Validate-CompletionJson.ps1
Validates completion JSON files (en-US.json, zh-CN.json) for syntax and structure.

**Checks:**
- Valid JSON syntax
- Required fields (meta, root, option, common_option)
- No duplicate command names
- Proper option structure
- Command and option descriptions

**Usage:**
```powershell
.\Validate-CompletionJson.ps1 -CompletionPath "path\to\completion"
```

### Validate-Hooks.ps1
Validates hooks.ps1 files for syntax and structure.

**Checks:**
- Valid PowerShell syntax
- Required function (handleCompletions)
- Proper function signature
- Common PSCompletions patterns

**Usage:**
```powershell
.\Validate-Hooks.ps1 -CompletionPath "path\to\completion"
```

## Test Results

All test scripts return:
- Exit code 0: All tests passed
- Exit code 1: Tests failed

The output includes:
- Color-coded results (green for success, red for errors, yellow for warnings)
- Detailed error messages
- Summary of errors and warnings

## Integration with CI/CD

These tests can be integrated into CI/CD pipelines to ensure completion packs meet quality standards before being merged.

**Example GitHub Actions workflow:**
```yaml
- name: Validate completion
  run: |
    pwsh -File tests/Run-AllTests.ps1 -CompletionPath "completions/pyenv"
```

## Best Practices

1. **Run tests before committing**: Always run tests before committing changes to a completion pack
2. **Fix all errors**: Ensure all tests pass before submitting PRs
3. **Address warnings**: Review and address warnings, though they won't block commits
4. **Test locally first**: Use the test scripts to validate your work before pushing

## Common Issues

### "Invalid JSON syntax"
- Check for missing commas, quotes, or brackets
- Use a JSON validator to check syntax
- Ensure special characters are properly escaped

### "Missing required field"
- Ensure all required fields are present in config.json
- Check that meta, root, option, and common_option exist in JSON files

### "PowerShell syntax error"
- Check for missing braces, parentheses, or quotes
- Use PowerShell ISE or VS Code to validate syntax
- Ensure proper escaping of special characters

## Contributing

When adding new tests:
1. Follow the existing naming convention (Validate-*.ps1)
2. Include comprehensive help documentation
3. Return appropriate exit codes
4. Provide clear error messages
5. Test with multiple completion packs

## Support

For issues or questions about the test framework:
- Check the PSCompletions documentation: https://pscompletions.abgox.com
- Open an issue on GitHub: https://github.com/abgox/PSCompletions/issues