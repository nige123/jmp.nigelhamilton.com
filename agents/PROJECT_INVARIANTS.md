# PROJECT_INVARIANTS.md

These repo-level rules must be preserved.

## 1. The model comes first

The domain model is the source of truth.
Parsing, CLI behaviour, help text, and output formatting are adapters around it.

## 2. Parse explicitly

If `jmp` accepts structured input, parse it deliberately.
Do not stack brittle regex substitutions where a grammar or explicit parser would be clearer.

## 3. Keep side effects at the edge

Filesystem access, environment access, shell invocation, clock access, and terminal-specific behaviour should stay at the boundaries.
Core logic should stay as pure and testable as practical.

## 4. Public command behaviour is a contract

Treat these as contracts unless the task explicitly changes them:

- command names
- argument rules
- help output structure
- exit codes
- machine-readable output
- file formats
- examples shown in docs and README

## 5. Do not guess silently

Invalid or ambiguous input should not be silently rewritten into a best guess unless that is an explicit feature with tests.

## 6. Stable output matters

Human-readable output should stay calm and consistent.
Machine-readable output should stay stable and predictable.

## 7. Tests are executable contracts

If behaviour changes, tests should show that clearly.
If a bug is fixed, add or update a regression test.

## 8. Keep the code teachable

New code should be easy for a careful maintainer to reason about.
Local clarity beats cleverness.
