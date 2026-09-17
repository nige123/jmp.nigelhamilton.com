# IZ4 before migration

`iz4 migrate` converted IZ4 to the Is For format on 2026-09-17. The new
file keeps only what the software is for, who it is for, and the
invariants that must remain true. Everything else it held is kept here
word for word, so nothing was lost. Move each part to wherever it now
belongs - the README, an ADR, tests or issues - or delete what no
longer matters.

## Invariant numbers

Invariants 0-4 are now the inherited foundation, so project invariants
were renumbered by adding 4:

| before | after |
|---|---|
| 1 | 5 |
| 2 | 6 |
| 3 | 7 |
| 4 | 8 |
| 5 | 9 |
| 6 | 10 |

## gist

jmp is a terminal tool for getting from "I found something" to "I am
editing it".  It takes search results, the output of any command, or
the places you jumped to recently, lets you pick a location and
inspect it in a preview, and opens your editor at that file and line
without leaving the terminal.  jmp is glue: it finds and presents
locations and hands the chosen one to the tools you already use.  The
Raku implementation is the reference; a Go port follows it.

## behaviours

- Running bare `jmp` replays recent destinations, so places you have already been are one keypress away.
- `jmp on <command>` runs any shell command and lets you jump to files referenced anywhere in its output, including error output - for example `git status`, `ls`, `find .`, `locate`, `tail` on a log, or a failing test run.
- `jmp in` searches inside files and presents the matching lines so you can jump to a specific hit.
- `jmp to` locates files, optionally at a line number.
- `jmp edit <filename> [<line-number>]` or `jmp edit <filename> '<search-terms>'` opens a file directly at a line or at the first matching line.
- `jmp config` opens the `~/.jmp` config file for editing, and `jmp help` shows command help.
- In the interface you move through hits with the arrow keys, press Enter to open the selected hit in your editor, Right to inspect a preview, Left to return from the preview to the results, `t` to enter a new text search, `o` to run a command and jump on its output, `h` to show help in the preview pane, and Esc to back out of a prompt or leave the interface.
- Help is shown in the preview pane alongside the results, listing each action once with a short explanation.
- jmp installs from the Raku ecosystem with `zef install jmp`, or from a local checkout while developing.

## constraints

- jmp runs on Raku / Rakudo and needs a terminal that supports `Terminal::UI`; it is a terminal-first tool with no other interface.
- jmp depends on commands the human already has in their shell - a text editor and a search command such as `rg` - and ships no editor or search engine of its own.
- jmp is distributed as a Raku ecosystem package installed with zef, and its versions are single integers: the release number.

## decisions

- 2026-09-12: Migrated intent from the legacy jmp.spoz2 (retired since/until dialect) into this root SPOZ2. All seven legacy invariants carry over. The legacy file recorded one supersession worth keeping: the history cap was 100 entries from release 52 and rose to 500 at release 53. The legacy file is removed; its history stays in git. go-jmp answers to this file and keeps a README pointer, not a rival spec.

## references


## Comments

    # What is this project supposed to do?
    # Humans and AI tools should treat this file as the authoritative
    # expression of intent.  Edit it directly or use `spoz2 add ...`.
    #
    # QUESTION for the maintainer: README.md documents `jmp to
    # '<search-terms>'` as searching inside files, while CHANGES.md (release
    # 53) gives searching in files to `jmp in` and makes `jmp to` locate
    # files, optionally at a line number.  The entries below follow
    # CHANGES.md.  If the README is the real intent, correct them.

