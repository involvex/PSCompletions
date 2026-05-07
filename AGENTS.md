# PSCompletions Agent Guide

## Repository Overview

PSCompletions is a **PowerShell module** (not JS/Node) providing enhanced tab completion via PSReadLine. Completion definitions are stored as JSON files downloaded on demand from GitHub/Gitee mirrors. The module is version 6.7.0.

## Directory Structure

```
module/PSCompletions/
  PSCompletions.psd1      # Module manifest (version, GUID, exports)
  PSCompletions.psm1     # Main entry: dispatches subcommands (add, rm, update, ...)
  core.ps1               # Init script: $PSCompletions global state + methods

completions/
  <name>/
    config.json          # language list, alias, hooks flag
    language/en-US.json  # Primary completion definition
    language/zh-CN.json  # Translation
    hooks.ps1            # Optional dynamic-completion logic

scripts/
  create-completion.ps1   # Scaffold a new completion pack (requires pwsh 7.0+)
  link-completion.ps1    # Create junction from module dir to local pack for dev
  update-content.ps1     # Regenerate completions.md, completions.json (CI owns this)
  publish-to-gallery.ps1 # Publish to PowerShell Gallery (on tag push)
  push-change.ps1        # Auto-commit helper used by CI

tests/
  Run-AllTests.ps1       # Main test runner
  Validate-Config.ps1    # Config validation
  Validate-CompletionJson.ps1  # JSON validation
  Validate-Hooks.ps1     # Hooks validation
  README.md              # Test documentation

module/CHANGELOG.md       # Version history
```

## Adding a New Completion Pack

```powershell
# 1. Scaffold (requires PowerShell 7.0+)
.\scripts\create-completion.ps1 -CompletionName <name>

# 2. Edit config.json — set languages, alias, hooks
# 3. Edit language/en-US.json — primary definition
# 4. Edit language/zh-CN.json — translated version
# 5. Optional: add hooks.ps1 if hooks:true in config.json
```

Completion definition schema (en-US.json example):
```json
{
  "meta": { "url": "...", "description": ["..."] },
  "root":    [{ "name": "add", "tip": ["..."], "next": [...] }],
  "option":  [{ "name": "--force", "tip": ["..."] }],
  "common_option": [{ "name": "--help", "tip": ["..."] }]
}
```

- `option` and `common_option` (not `options` / `common_options`) — changed in v6.7.0
- `repeat` on a command means it can appear multiple times without consuming input
- `next` is a subcommand array

## Testing Completion Packs

**IMPORTANT**: Always run tests before committing completion pack changes.

```powershell
# Run all tests for a completion pack
.\tests\Run-AllTests.ps1 -CompletionPath "completions\<name>"

# Run specific tests
.\tests\Validate-Config.ps1 -CompletionPath "completions\<name>"
.\tests\Validate-CompletionJson.ps1 -CompletionPath "completions\<name>"
.\tests\Validate-Hooks.ps1 -CompletionPath "completions\<name>"
```

### What the Tests Validate

1. **Config Validation** (`Validate-Config.ps1`):
   - Valid JSON syntax
   - Required fields (language)
   - Valid language codes
   - Proper hooks flag
   - Hooks.ps1 existence when hooks is true

2. **JSON Validation** (`Validate-CompletionJson.ps1`):
   - Valid JSON syntax
   - Required fields (meta, root, option, common_option)
   - No duplicate command names
   - Proper option structure
   - Command and option descriptions

3. **Hooks Validation** (`Validate-Hooks.ps1`):
   - Valid PowerShell syntax
   - Required function (handleCompletions)
   - Proper function signature
   - Common PSCompletions patterns

### Test Results

- Exit code 0: All tests passed ✅
- Exit code 1: Tests failed ❌

All tests provide color-coded output with detailed error messages.

### Common Test Failures

1. **Invalid JSON syntax**: Check for missing commas, quotes, or brackets
2. **Missing required fields**: Ensure all required fields are present
3. **PowerShell syntax errors**: Check for missing braces, parentheses, or quotes
4. **Duplicate command names**: Ensure all command names are unique

### Testing Best Practices

1. **Run tests before committing**: Always validate your work
2. **Fix all errors**: Ensure all tests pass before submitting PRs
3. **Address warnings**: Review warnings, though they won't block commits
4. **Test locally first**: Use the test scripts to validate before pushing

## Testing a Completion Pack Locally

```powershell
# Create a junction so the module sees your local pack
.\scripts\link-completion.ps1 -CompletionName <name>

# Reload module and test
Import-Module .\module\PSCompletions -Force
psc   # reloads key bindings and data
# Now type the command, press Space+Tab
```

Run `psc` (not just re-import) to ensure key bindings are rebound.

## Module Internals

| Path variable | Value |
|---|---|
| `$PSCompletions.path.root` | Module root |
| `$PSCompletions.path.completions` | `$root\completions` — where linked/downloaded packs live |
| `$PSCompletions.path.data` | `$root\data.json` — user's installed list, aliases, config |
| `$PSCompletions.path.temp` | `$root\temp` — cached remote list, update markers |
| `$PSCompletions.path.completions_json` | `$temp\completions.json` — remote catalog |
| `$PSCompletions.path.order` | `$temp\order` — per-cmd history-sort order |

User data lives outside the repo at the module install location.

## Generated Files (Do Not Edit Manually)

- `completions.md` and `completions.zh-CN.md` — auto-generated tables
- `completions.json` — remote catalog with list/update hashes/meta

These are regenerated by `scripts\update-content.ps1` on every push to main (via CI). If you need to update them locally, run the script.

## Content Update Workflow

```powershell
.\scripts\update-content.ps1
```

This runs in CI on every push to `main`. It:
1. Regenerates `completions.md` / `completions.zh-CN.md`
2. Runs `sort-completion.ps1`
3. Generates `completions.json`
4. Auto-commits via `push-change.ps1` (message: `chore: automatically update some content [skip ci]`)

## Publishing to PowerShell Gallery

1. Update `module/PSCompletions/PSCompletions.psd1` `ModuleVersion`
2. Update `module/CHANGELOG.md`
3. Commit and tag: `git tag v<version>` then `git push origin <tag>`
4. CI workflow `publish-to-gallery.yml` triggers on tags — runs `scripts\publish-to-gallery.ps1`

## CI/CD Workflows

| Workflow | Trigger | Action |
|---|---|---|
| `update-content.yml` | Push to main | Runs `update-content.ps1`, auto-commits |
| `publish-to-gallery.yml` | Tag `v*` or manual dispatch | Publishes to PowerShell Gallery |
| `deploy.yml` | After update-content completes | GitHub Pages (Jekyll site) |
| `sync-github-to-gitee.yml` | After update-content completes | Mirrors to Gitee |

## Remote Content & Mirrors

Default base URLs by UI culture:
- `zh-CN`: Gitee first → GitHub → GitHub Pages
- Other: GitHub first → Gitee → GitHub Pages

Override with `psc config url <url>`.

## Quirks & Gotchas

- **GUID marker**: `00929632-527d-4dab-a5b3-21197faccd05` is used internally to tag completion items during parsing — do not change
- **Language fallback**: en-US is canonical; zh-CN is translated. If a language is missing, first language in config is used.
- **Desktop PowerShell (5.1)**: Line theme customization is blocked (`menu line_theme` commands throw)
- **`enable_cache=0`**: Disables completion caching; slower but always fresh
- **`psc` command**: Always rebinds keys and reloads data even if cache is disabled
- **Aliases**: Declared in `config.json` `alias` array; `enable_auto_alias_setup=1` auto-runs `Set-Alias`
- **History sorting**: Background jobs saved under `temp\order\<cmd>.json`; order by usage frequency

## Versioning & Changelog

- Version in three places (must stay in sync):
  - `module/PSCompletions/PSCompletions.psd1` → `ModuleVersion`
  - `module/PSCompletions/core.ps1` → `version` field
  - `module/CHANGELOG.md` → unreleased section
- Use **semantic versioning**
- Changelog has English + Chinese sections

## Testing

### Automated Tests

The repository includes automated tests in the `tests/` directory:

```powershell
# Run all tests for a completion pack
.\tests\Run-AllTests.ps1 -CompletionPath "completions\<name>"

# Run specific tests
.\tests\Validate-Config.ps1 -CompletionPath "completions\<name>"
.\tests\Validate-CompletionJson.ps1 -CompletionPath "completions\<name>"
.\tests\Validate-Hooks.ps1 -CompletionPath "completions\<name>"
```

See `tests/README.md` for detailed documentation.

### Manual Testing

For interactive testing:
- Link the completion pack
- Import the module fresh
- Exercise Tab completion in an interactive PowerShell session
- For JSON changes, validate with `ConvertFrom-Json` (will throw on syntax errors)

## References

- Website / docs: https://pscompletions.abgox.com
- Hooks authoring: https://pscompletions.abgox.com/completion/hooks
- Contributing (minimal): `.github/contributing.md`
