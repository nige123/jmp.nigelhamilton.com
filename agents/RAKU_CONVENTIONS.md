# RAKU_CONVENTIONS.md

Coding conventions for this Raku repo.

## General

- Use 4-space indentation.
- Match the surrounding style where it is consistent.
- Preserve the repo's existing Raku version declaration.
- Prefer clear names over terse names.
- Keep routines focused and easy to scan.
- Avoid unnecessary metaprogramming.

## Typical layout

Use standard Raku layout unless the repo already uses a different established pattern:

- `lib/` for modules
- `bin/` for executables
- `t/` for tests
- `xt/` for slower or integration-heavy tests
- `resources/` for packaged resources

## Signatures and types

- Prefer explicit signatures where they improve clarity.
- Prefer named parameters for optional config and booleans.
- Use type constraints where they reduce ambiguity and real bugs.
- Do not add types just for decoration.

## Raku-native design

Prefer:

- `class` for clear domain objects
- `role` for shared behaviour
- `grammar` and actions for structured parsing
- `enum` for real state sets
- `subset` for semantically constrained values
- `multi` only when it makes behaviour clearer

Avoid forcing patterns from other ecosystems onto Raku.

## Parsing

If input has real structure, prefer explicit parsing rather than chained ad hoc substitutions.
Grammars are often the right tool when the accepted input language matters.

## Error handling

- Use clear domain outcomes for expected cases.
- Use exceptions for truly exceptional conditions.
- Prefer typed exceptions when useful.
- Do not swallow failures silently.

## State and side effects

- Avoid hidden mutable global state.
- Inject dependencies where practical.
- Keep filesystem, environment, shell, and time access at the edge.

## Output

- Keep human-readable output concise and stable.
- Keep machine-readable output strict and predictable.
- Do not mix debug chatter into normal output paths.

## Comments and docs

- Comment the why, not the obvious what.
- Update examples when command syntax or behaviour changes.
