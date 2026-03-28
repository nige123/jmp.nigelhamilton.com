---
applyTo: "lib/JMP/UI.rakumod"
---

# Terminal::UI Best Practices for JMP

These rules distil patterns observed in the Terminal::UI 0.1.13 example files
and confirmed against its source.  Follow them whenever editing `JMP::UI`.

## Heights — use `fr => 1` for flexible panes

```raku
$ui.setup(heights => [1, 15, fr => 1, 1]);
```

- Plain integers set fixed row counts.
- `fr => N` is a fractional (flexible) specifier; Terminal::UI distributes
  whatever rows remain after fixed panes are allocated.
- **Do not** manually detect screen rows or compute pane heights.  The
  framework handles terminal resize automatically.

## Pane variables — use destructuring

```raku
my ($title, $results, $preview, $footer) = $ui.panes;
```

Prefer this over indexed access (`$ui.panes[0]`, etc.) for readability.

## Display-only panes — disable selection and auto-scroll

```raku
$title.selectable  = False;
$title.auto-scroll = False;
$footer.selectable  = False;
$footer.auto-scroll = False;
```

Tab-focus navigation skips non-selectable panes.  Setting `auto-scroll =
False` prevents content added with `put` from scrolling the pane.

## Key bindings — keep one real `'quit'` action

`interact()` resolves a `done` key by finding the binding mapped to the
`'quit'` action.  Always preserve at least one such mapping:

```raku
$ui.bind(Q => 'quit', q => 'jmp-quit', x => 'jmp-quit', X => 'jmp-quit');
```

## Synchronous immediate quit — use `on-sync`

```raku
$ui.on-sync(|{
    'jmp-quit' => -> {
        $ui.shutdown;
        die $quit-token;
    }
});
```

`on-sync` fires in the event loop without deferral, so the TUI shuts down
before the next repaint.

## Terminal restoration — always clean up in `LEAVE`

```raku
LEAVE {
    $ui.shutdown;
    run 'stty', 'sane';
    print "\n";
    $*OUT.flush;
}
```

`stty sane` restores cooked-mode line discipline after raw terminal input.
The trailing newline ensures the shell prompt appears on a fresh line.

## Interact + catch pattern

```raku
try {
    $ui.interact;
    CATCH {
        default {
            .rethrow if .message ne $quit-token;
        }
    }
}
```

`interact` blocks until the done key is pressed.  The `CATCH` block silences
only the controlled `$quit-token` exception; all other errors propagate.

## Pane event handlers

```raku
$results.on: select => -> :%meta { ... };
$preview.on: select => -> :%meta { ... };
```

Pass metadata through `put` and retrieve it in the handler:

```raku
$results.put($hit.render, meta => { hit-index => $index });
```

## Pane-level bindings for scrolling / paging

```raku
$ui.bind('pane', CursorRight => 'page-down', l => 'page-down');
$ui.bind('pane', CursorLeft  => 'page-up',   h => 'page-up');
```

## Editor round-trip — use `pause-and-do` + `refresh`

```raku
$ui.pause-and-do({
    $!editor.edit($!title, $hit);
});
$ui.refresh(:hard);
```

`pause-and-do` suspends the TUI, runs the block (which may take over the
terminal), then resumes.  `:hard` forces a full redraw.
