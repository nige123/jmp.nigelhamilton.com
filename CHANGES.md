# Changes

Date: 2026-03-28

## Summary

This commit captures all currently modified files in the working tree.

## Highlights

- Added shared version module and wired version reporting through it.
- Expanded TUI behavior in `JMP::UI`:
  - right/enter selection flow for results and preview
  - left-arrow back behavior from preview
  - context-sensitive escape behavior
  - centered footer with right-aligned version
  - help key support (`h` and `?`)
  - inline `[t]o` search prompt in title area
- Updated CLI wiring to use shared version constant.
- Added version test coverage and editor-input-related test scaffolding.
- Updated repository metadata version.
- Included all additional file additions/deletions present in the current working tree.

## Validation Notes

- Diagnostics for recently touched files were checked in-editor.
- Terminal-mode test output capture was environment-dependent during this session.

## Update: `jmp on` Consistency (2026-03-28)

### Summary

Aligned command usage so command-output mode is documented and surfaced as `jmp on <command>` consistently across CLI help and README examples.

### Highlights

- CLI usage examples now use `jmp on ...` for command-output workflows.
- README command-output examples now use `jmp on ...` consistently.
- TUI footer action hint uses `[o]n cmd` to match the command name and the in-TUI output prompt flow.

### Validation Notes

- Full test suite passed with this update:
  - `t/00-load.t`
  - `t/17-rg-default.t`
  - `t/18-preview-pane.t`
  - `t/19-footer-pane.t`
  - `t/21-editor-input.t`
  - `t/22-version.t`
  - `t/23-output-action.t`
  - `t/meta.t`
