# JMP_SPECIFIC.md

Repo-specific guidance for the `jmp` Raku command line utility.

Because this is a command line tool, agents must be especially careful with behaviour users may script against.

## Protect the CLI contract

Before changing command behaviour, check all of these:

- command and subcommand names
- flag names and aliases
- positional argument meaning
- default behaviour
- help and usage text
- exit codes
- stdout vs stderr
- any documented or implied machine-readable mode

## Prefer stable command semantics

A small internal cleanup must not change the user-facing contract by accident.

Examples of risky accidental changes:

- moving a warning from stderr to stdout
- changing default sort or traversal order
- changing path normalization rules
- changing whether a missing value is ignored, warned on, or fatal
- changing wording that external scripts or tests rely on
- changing an exit code from non-zero to zero or vice versa

## Keep command entrypoints thin

Prefer this shape:

- parse CLI options at the command boundary
- normalize inputs at the edge
- pass explicit values into a small internal API
- format output in one place
- keep the business logic independent from terminal and shell concerns

## For filesystem or path logic

Be careful about:

- relative vs absolute paths
- symlink behaviour
- home directory expansion
- missing paths
- path normalization on different systems
- not writing or deleting unexpectedly

## For text output

Preserve:

- predictable line structure
- stable headings
- single-purpose messages
- concise errors
- calm help text

## For future change decisions

Prefer adding a clear new flag or mode over silently changing old behaviour.
