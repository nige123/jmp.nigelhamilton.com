# START_HERE.md

Start here before changing code.

## First classify the task

Work out which kind of change this is:

- bug fix
- refactor
- new feature
- parser or grammar work
- command-line behaviour
- help text or docs
- packaging or release work
- performance work

## Then answer these questions

1. What is the smallest correct layer for the change?
   - domain model
   - parser or grammar
   - CLI dispatch
   - formatter or renderer
   - filesystem boundary
   - shell integration
   - test only
   - docs only

2. What must remain true after the change?
   - command names
   - flags and arguments
   - exit codes
   - stdout and stderr expectations
   - machine-readable output format
   - documented examples
   - file format compatibility

3. What is the smallest patch that fully solves the problem?

## Read before writing

Read:

- the touched module
- the nearest tests
- the calling code
- the help text or docs for that surface
- `agents/JMP_SPECIFIC.md` if the command line is involved

## Choose the right role file

- `agents/ARCHITECTURE_ARCHIE.md` for boundaries, naming, module layout, parsing strategy
- `agents/BUILDER_BRIAN.md` for implementation
- `agents/UX_ARIA.md` for CLI/TUI/help text/docs
- `agents/RELIABILITY_SEAN.md` for runtime, packaging, CI, performance, idempotence
- `agents/RED_TEAM_NORBERT.md` for weird inputs, safety, shell, destructive operations, contract breakage

## Repo bias

Bias toward:

- explicit design
- small modules
- clear command semantics
- deterministic tests
- boring, durable code

Bias against:

- speculative abstraction
- global state
- output churn
- accidental breaking changes
- convenience wrappers that obscure control flow
