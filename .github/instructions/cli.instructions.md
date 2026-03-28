---
applyTo: "{bin/**,lib/**,t/**}"
---

CLI-specific instructions for the `jmp` command:

- Treat command names, flags, positional arguments, help text, exit codes, stdout, and stderr as public contracts.
- A refactor must not change user-visible behaviour by accident.
- Keep command entrypoints thin.
- Normalize inputs at the edge and pass explicit values inward.
- Add or update tests for all behaviour changes.
- Check stderr vs stdout carefully.
- Prefer adding a clear new flag over silently changing legacy behaviour.
