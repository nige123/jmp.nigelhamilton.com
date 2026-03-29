# jmp

`jmp` helps you jump from search results, command output, and recent history straight into your editor.

It is built for everyday workflow navigation: search across files, inspect a preview, and open the right location without leaving the terminal.

![jmp demo](https://raw.githubusercontent.com/nige123/jmp.nigelhamilton.com/master/images/demo.gif)

## Install

Install from the ecosystem:

```bash
zef install jmp
```

Install from a checkout while developing locally:

```bash
zef install .
```

## Requirements

- Raku / Rakudo
- A terminal that supports `Terminal::UI`
- A text editor command available in your shell
- A search command such as `rg` configured in `~/.jmp`

## Commands

```text
jmp                                         show most recent hits
jmp to '[<search-terms> ...]'               search files and jump to matching lines

# jmp on files in command output. For example:
jmp on locate README                        files in the filesystem
jmp on tail /some.log                       files mentioned in log files
jmp on ls                                   files in a directory
jmp on find .                               files returned from the find command
jmp on git status                           files in git
jmp on perl test.pl                         Perl output and errors
jmp on raku test.raku                       Raku output and errors

jmp config                                  edit ~/.jmp config to set editor and search commands
jmp help                                    show command help

jmp edit <filename> [<line-number>]         start editing at a line number
jmp edit <filename> '[<search-terms> ...]'  start editing at a matching line
```

## Typical Use

Search the codebase and open the right match:

```bash
jmp to parser grammar token
```

Drive `jmp` from another command:

```bash
jmp on git status
jmp on rg TODO
jmp on prove -e raku t/
```

Open a file directly at a line:

```bash
jmp edit lib/JMP/UI.rakumod 120
```

## TUI Keys

Inside the interface you can:

- move through hits with the arrow keys
- press `Enter` to open the selected hit in your editor
- press `Right` to inspect a preview
- press `Left` to return from preview to results
- press `t` to enter a new text search
- press `o` to run a command and jump on its output
- press `h` to show help in the preview pane
- press `Esc` to back out of prompts or leave the interface

## Configuration

Run:

```bash
jmp config
```

This opens `~/.jmp`, where you can configure the editor command and the search command used by `jmp to`.

## Release Notes

See [CHANGES.md](CHANGES.md) for release history.

## Support

- Issues: <https://github.com/nige123/jmp.nigelhamilton.com/issues>
- Source: <https://github.com/nige123/jmp.nigelhamilton.com>
