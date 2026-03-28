# CHANGE_PROTOCOL.md

Required protocol for safe changes.

## Core rule

Pause and check invariants before changing code.

## Standard sequence

### 1. Frame the change

State clearly:

- what is changing
- why it is changing
- what must remain unchanged

### 2. Find the narrowest responsible layer

Change the lowest correct layer.

Examples:

- parse bug -> parser or grammar
- domain rule bug -> model or service layer
- output wording -> renderer or formatter
- CLI option issue -> command boundary

Do not patch around a core bug in outer layers.

### 3. Prefer minimal diffs

Good patches:

- touch as few files as practical
- solve one coherent problem
- are easy to review and revert
- keep mechanical cleanup separate from behavioural change when possible

### 4. Tests move with behaviour

Add or update tests for:

- the bug being fixed
- the new supported case
- the invariant being protected

### 5. Verify honestly

Run targeted checks first, then broader checks as appropriate.

### 6. Review through a hostile lens

Ask before finalizing:

- what weird input breaks this
- what public contract changed
- what assumption is now implicit
- what output changed
- what side effect could happen twice

### 7. Summarize honestly

Final summaries must state:

- what changed
- what did not change
- what was verified
- any remaining risk
