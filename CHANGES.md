# Changes

Date: 2026-03-28

## Release 54 (2026-09-30)

### Summary

This release brings the Raku implementation level with go-jmp v70, and adds a reproducible standalone build with Raku++.

### Highlights

- `[t]o file` in the interface: press `t`, type a filename and press Enter to locate it on the filesystem, alongside `[i]n search` and `[o]n cmd`.
- The footer has three zones: a `current/total` cursor counter for the focused pane at the left, the actions centred, and the version at the right. The actions give way first when the terminal is narrow.
- The results pane takes 35% of the terminal height and the preview the rest, instead of a fixed 15 rows.
- The preview shows the file's lines without line-number prefixes; an empty file previews as one empty line.
- Config values have double quotes stripped, indented comments are skipped, and `jmp` quotes the filename it passes to the editor itself, so the default editor template is now `nano +[-line-number-] [-filename-]`. Unknown `[-tokens-]` in a template are left as they are.
- `jmp edit <file>` opens at line 1; `jmp edit` and `jmp to` without a filename, and `jmp back` with a count that is not a number, fail with a one-line error and exit 1; `jmp version` and `jmp help` ignore extra arguments; `jmp to <file> <not-a-number>` locates the file.
- Titles and history entries are normalised to `jmp`, `jmp in ...`, `jmp on ...` and `jmp to ...`.
- `jmp on` interleaves standard output and standard error as they happen, and file references in error output match with flexible spacing (`at FILE (Module):N`, `at FILE (Module) line N`); a line number below 1 opens line 1; tabs survive control-character stripping. `jmp in` and `jmp to` no longer let the search tool's standard error write over the interface.
- `rakupp/build.sh` builds a standalone `build/jmp` with Raku++ (4.0.1 and 5.1.0), applying the `Terminal::UI` patches Raku++ needs; the test suite has a `JMP_TEST_BIN` seam to run the CLI tests against the compiled file.
- The preview pane loads its window without scrolling the terminal once per line, so it lands on the selected line in a fraction of the time (about five times faster under Raku++).
- The interface builds its panes through Terminal::UI's array path: Rakudo 2026.07 reads the callback candidate's `Callable :&heights!` as `Callable[Callable]`, which left the interface unable to start under Rakudo.
- Bumped project version to `54` in code and metadata.

### Validation Notes

- `TERM=dumb prove -e "raku -Ilib" t/` passed (15 files, 109 tests).
- `TERM=dumb prove -e "rakupp -Ilib" t/` passed under Raku++ 4.0.1 and 5.1.0 (one `use-ok` skipped, because Raku++ runs an imported MAIN inside `use-ok`).
- `JMP_TEST_BIN=build/jmp prove -e "rakupp -Ilib" t/22-version.t t/30-cli-errors.t` passed against the compiled file, which also ran alone in an empty directory with only the system `PATH`.
- The interface was driven in a pseudo-terminal under both Rakudo and the compiled file: results, preview at the selected line, the cursor counter and quitting all work.

## Release 53 (2026-08-31)

### Summary

This release backports the three clean command verbs from the Go implementation and grows the jmp history so more destinations stay one keypress away.

### Highlights

- `jmp on <command>` jumps on files found in any command's output, `jmp in` searches in files, and `jmp to` locates files (optionally at a line number).
- The config file gains `locate.command.template` and cross-platform alternatives for all tools.
- The `~/.jmp.hist` history is now capped at the last 500 entries (previously 100), per the `every-jmp-is-remembered` invariant (since 53) in `IZ4`; bare `jmp` replays up to 500 recent entries.
- Bumped project version to `53` in code and metadata.

### Validation Notes

- `TERM=dumb prove -e "raku -Ilib" t/` passed (10 files, 48 tests), including the new `t/25-history-cap.t` covering the 500-entry cap.

## Release 52 (2026-03-29)

### Summary

This release finishes the raku.land and zef metadata cleanup by making the repository source URL fully ecosystem-compliant.

### Highlights

- Updated `support.source` to the Git repository URL ending in `.git` to satisfy `Test::META` expectations.
- Bumped project version to `52` in code and metadata.

### Validation Notes

- `TERM=dumb prove -e raku t/meta.t t/00-load.t t/22-version.t` passed after the metadata cleanup.

## Release 51 (2026-03-29)

### Summary

This release prepares `jmp` for the Raku ecosystem with a fuller package README and corrected distribution metadata for zef and raku.land.

### Highlights

- Expanded the README with install instructions, command overview, workflow examples, TUI keys, and configuration notes.
- Moved `Test::META` from runtime dependencies to `test-depends`.
- Switched the distribution `source-url` to HTTPS and added the repository URL under `support.source`.
- Bumped project version to `51` in code and metadata.

### Validation Notes

- Packaging metadata and README were updated for release consumption.
- Targeted packaging checks were run after these changes.

## Release 50 (2026-03-28)

### Summary

This release replaces popup help with preview-pane help content and simplifies help text so actions are listed once with short explanations.

### Highlights

- `h` now routes to help shown directly in the preview pane.
- Help no longer relies on the popup dialog path for the primary help key.
- Help text is concise and non-repetitive, with single-line action explanations.
- Fixed title and footer pane rendering with line updates for persistent chrome.
- Version bumped to `50` in code and metadata.

### Validation Notes

- `lib/JMP/UI.rakumod` compile check passed.
- CLI version output reports `jmp - version 50`.

## Release 43 (2026-03-28)

### Summary

This release finalizes TUI help dialog behavior and includes the latest preview and versioning updates.

### Highlights

- Help dialog can now be dismissed with Enter on OK.
- Header and footer are restored after closing help, preventing blank chrome after dialog dismissal.
- Added bounded preview-window rendering for faster preview pane updates on large files.
- Added preview-window regression tests.
- Bumped project version to `43` in code and metadata.

### Validation Notes

- Version and load tests were previously run during this change series (`t/00-load.t`, `t/22-version.t`).
- Full suite and targeted pane/output tests were run earlier in this session for the preview/help change set.

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
