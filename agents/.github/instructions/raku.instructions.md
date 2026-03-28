---
applyTo: "**/*.{raku,rakumod,rakutest,p6,pm6,pl6,t}"
---

Raku-specific instructions for this repository:

- Preserve the repository's existing Raku version requirement.
- Prefer explicit signatures, named parameters for optional config, and small focused routines.
- Prefer `class`, `role`, `grammar`, `enum`, and `subset` when they clarify the design.
- Avoid forcing patterns from other ecosystems onto Raku.
- If structured input is involved, prefer explicit parsing over ad hoc regex chains.
- Keep side effects at the edge.
- Avoid hidden mutable global state.
- Keep machine-readable output stable.
- Keep human-readable output concise and calm.
