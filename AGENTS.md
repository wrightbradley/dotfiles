When making commits, do not include anything like the following:

```
🤖 Generated with [opencode](https://opencode.ai)

Co-Authored-By: opencode <noreply@opencode.ai>
```

# AGENTS.md

## Build, Lint, and Test Commands

- **Lint all files:**
  - Run `pre-commit run --all-files` to lint and autoformat code (YAML, Markdown, shell, etc.).
  - Shell scripts: Run `shellcheck <script>` for static analysis.
  - YAML: Use `yamllint` for YAML files.
  - Markdown: Use `markdownlint` for Markdown files.
  - Prose: Use `vale` for prose/style linting.
- **CI:** Linting is enforced via GitHub Actions workflows.
- **Tests:** No automated tests are defined; focus is on configuration and linting.

## Code Style Guidelines

- **Imports:** Source shell scripts with explicit paths; avoid ambiguous relative imports.
- **Formatting:**
  - Use Prettier, yamllint, and markdownlint for formatting.
  - Follow .editorconfig for indentation and line endings.
- **Types:** Use clear, descriptive variable names in shell and YAML.
- **Naming:** Use lowercase, hyphen-separated filenames for scripts and configs.
- **Error Handling:**
  - Shell: Use `set -euo pipefail` where possible; check exit codes.
  - YAML: Validate syntax before committing.
- **Secrets:** Do not commit secrets; gitleaks is enforced in CI.
- **General:** All changes should pass pre-commit hooks and CI linting before merging.
