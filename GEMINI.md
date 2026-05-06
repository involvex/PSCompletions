# PSCompletions (psc)

A completion manager for a better and simpler tab-completion experience in PowerShell. It provides a built-in completion library, a powerful module completion menu, and multi-language support.

## Project Overview

- **Core Technologies**: PowerShell (pwsh/powershell), PSReadLine.
- **Architecture**:
    - **Module**: Located in `module/PSCompletions`, containing the main logic (`PSCompletions.psm1`, `core.ps1`).
    - **Completions Library**: Located in `completions/`, where each tool (e.g., `git`, `docker`) has its own directory with `config.json`, `hooks.ps1`, and a `language/` subdirectory for translations.
    - **Scripts**: Maintenance scripts in `scripts/` for updating content, creating completions, and publishing.
    - **Data**: `completions.json` stores the compiled completion data.

## Building and Running

Since this is a PowerShell module, "building" primarily involves compiling the completion library into the central `completions.json` and `completions.md` files.

### Key Commands

- **Update Content**: Compiles the completion library.
    ```powershell
    pwsh ./scripts/update-content.ps1
    ```
- **Create New Completion**: Scaffold a new completion.
    ```powershell
    pwsh ./scripts/create-completion.ps1 -name <tool-name>
    ```
- **Link Completion**:
    ```powershell
    pwsh ./scripts/link-completion.ps1
    ```
- **Import Module (Local Development)**:
    ```powershell
    Import-Module ./module/PSCompletions/PSCompletions.psd1 -Force
    ```

## Development Conventions

- **Completion Structure**:
    - `config.json`: Metadata for the completion.
    - `hooks.ps1`: PowerShell script for dynamic completion logic (e.g., fetching git branches).
    - `language/*.json`: Translation files for completion descriptions.
- **Naming**: Follow PowerShell naming conventions (Verb-Noun) for module functions where applicable.
- **Multi-language**: Always provide at least `en-US.json` and `zh-CN.json` for new completions.
- **Scripts**: Most maintenance scripts are located in `scripts/` and should be run with PowerShell 7 (pwsh).

## File Structure Highlights

- `module/PSCompletions/`: Main module files.
- `completions/`: Individual completion definitions.
- `scripts/`: Development and maintenance tools.
- `schema/`: JSON schemas for configuration files.
- `completions.json`: The generated "database" of completions.
- `README.md`: End-user documentation.
