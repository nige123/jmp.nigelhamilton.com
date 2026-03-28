# TEST_AND_VERIFY.md

Verification rules for this repo.

## Principle

Do not say the change works unless you ran relevant checks.

## Default order

Prefer the repo's canonical test or task runner if one exists.
Otherwise use the smallest useful set first.

### 1. Compile-check touched files

Examples:

```bash
raku -Ilib -c lib/JMP.rakumod
raku -Ilib -c bin/jmp
```

### 2. Run targeted tests

Examples:

```bash
prove -e raku -v t/command-line.t
prove -e raku -v t/parser.t
```

### 3. Run the broader test suite

```bash
prove -e raku -r t
```

### 4. Run packaging checks if the repo uses them

```bash
zef test .
```

## For CLI verification

Check:

- exit code
- stdout
- stderr
- help text if changed
- machine-readable output if relevant

## For parser work

Add tests for:

- valid inputs
- invalid inputs
- ambiguous-looking inputs
- whitespace and normalization edge cases
- round-trips if they matter

## For filesystem work

- use temp directories
- do not rely on ambient working directory unless the command is specifically about it
- test missing-path and permission-failure cases where relevant

## Verification note format

Summaries should say:

- compile checks run
- tests run
- checks not run
- remaining risk, if any
