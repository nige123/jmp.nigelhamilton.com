# Copilot instructions for the `jmp` Raku CLI repo

This repository is a Raku command line utility.
Follow the top-level `AGENTS.md` file and the documents in `agents/`.

Repository-wide rules:

- Prefer Raku-native solutions. Do not introduce Python-, JavaScript-, or Java-style structure unless the repo already uses it.
- Preserve existing command names, flags, exit codes, stdout, stderr, and help text unless the task explicitly changes them.
- Keep the command entrypoint thin. Put parsing at the boundary and keep business logic separate from CLI wiring, filesystem access, shelling out, and formatting.
- Use 4-space indentation.
- Prefer small, reviewable diffs.
- Update tests with behaviour changes.
- Add regression tests for bug fixes.
- Do not add dependencies without strong justification.
- Do not claim code is verified unless relevant checks were actually run.
- For parser or command-line changes, read `agents/JMP_SPECIFIC.md` before editing.
- For architecture work, use the Archie lens.
- For implementation work, use the Brian lens.
- For CLI/help/docs wording, use the Aria lens.
- For reliability, CI, packaging, or performance, use the Sean lens.
- For adversarial review and edge cases, use the Norbert lens.
