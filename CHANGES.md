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
