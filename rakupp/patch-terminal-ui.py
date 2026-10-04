#!/usr/bin/env python3
"""Patch Terminal::UI 0.1.14 so it runs under Raku++ (rakupp).

Usage: patch-terminal-ui.py <unpacked Terminal-UI source dir>

Each replacement works around one Raku++ gap met while building jmp; every
one behaves the same on Rakudo. Re-probed on 2026-09-30 against Raku++ 5.1.0.

Still needed on 5.1.0:
  - `@$arr[$i] = ...` dies with "Target is not assignable" (ash/rakupp#122)
  - `for @a.kv -> $i, $x is rw` does not write through (ash/rakupp#123)
  - `.trans("\t" => "  ", :g)` reads `:g` as one more mapping and blanks every "g" (ash/rakupp#120)
  - a handle opened on /dev/tty never delivers input, and `$*IN.read(N)`
    waits for all N bytes: Input.rakumod is replaced with a read(2) reader (ash/rakupp#121)
  (also outside this file: `--exe` never invokes an imported MAIN (ash/rakupp#112),
   so build.sh uses --aot; and `use-ok` runs an imported MAIN (ash/rakupp#124),
   which t/00-load.t skips)

Fixed in 5.1.0, patches kept because they are harmless and 4.0.1 needs them:
  - `$a [&($op)] $b` (infix-call syntax) did not parse
  - a bare `return without $x;` died with "Undefined routine 'without'"
  - `my ($s, @l) := (Str, @arr)` put the array inside one element
  - keys of a SetHash came back as Str, not the objects put in
"""
import sys, re
import os
root = sys.argv[1]
here = os.path.dirname(os.path.abspath(__file__))
def patch(path, pairs):
    p = f"{root}/{path}"; s = open(p).read(); changed = False
    for old, new in pairs:
        if new in s and old not in s: continue
        assert old in s, f"{path}: missing: {old[:60]!r}"
        s = s.replace(old, new); changed = True
    open(p, 'w').write(s); print(("patched " if changed else "already ") + path)

patch('lib/Terminal/UI.rakumod', [
    ('$current = ($current [&($op)] 1) % $count;', '$current = $op($current, 1) % $count;'),
])
# bare `return without` dies under Raku++
p = f"{root}/lib/Terminal/UI/Pane.rakumod"; s = open(p).read()
s2 = re.sub(r'^(\s*)return without ', r'\1return Nil without ', s, flags=re.M)
open(p, 'w').write(s2); print(("patched " if s2 != s else "already ") + "Pane.rakumod (return without)")
patch('lib/Terminal/UI/Pane.rakumod', [
    ('my ($next,@left) := self!raw2line-hardwrap(@rem, :indent($indent + ($first ?? 0 !! $hang)));',
     'my ($next, $left) = self!raw2line-hardwrap(@rem, :indent($indent + ($first ?? 0 !! $hang))); my @left = @$left;'),
    ('my ($next,@left) := self!raw2line-wordwrap(@rem, :indent($indent + ($first ?? 0 !! $hang)));',
     'my ($next, $left) = self!raw2line-wordwrap(@rem, :indent($indent + ($first ?? 0 !! $hang))); my @left = @$left;'),
    ('''  $s.trans("\\t" => '  ', :g);''', '''  $s.subst("\\t", '  ', :g);   # subst, not trans: Raku++ 4.0.1 reads trans's :g as a mapping'''),
])
patch('lib/Terminal/UI/Frame.rakumod', [
    ('''    for @$heights.kv -> $i, $h is rw {
      if $h ~~ Pair {
        @changed.push: $i;
        $h = $fr-base * $h.value;
      }
    }
    while @$heights.sum < $want {
      @$heights[@changed[ $++ ]]++;
    }''', '''    for @$heights.kv -> $i, $h {
      if $h ~~ Pair {
        @changed.push: $i;
        $heights[$i] = $fr-base * $h.value;
      }
    }
    my $adjust = 0;
    while @$heights.sum < $want {
      $heights[@changed[ $adjust++ % @changed.elems ]]++;
    }'''),
])
patch('lib/Terminal/UI/Screen.rakumod', [
    ('has SetHash $!frames;', 'has @!frames;'),
    ('  $!frames{ $f } = 1;\n', '  @!frames.push($f) unless @!frames.first(* === $f);\n'),
    ('  $!frames{ $f }:delete;', '  @!frames = @!frames.grep(* !=== $f);'),
    ('$!frames.keys.sort;', '@!frames;'),
    ('$!frames.keys', '@!frames'),
])
s = open(f"{root}/lib/Terminal/UI/Screen.rakumod").read(); assert '$!frames' not in s

# the key reader: read(2) on standard input under Raku++, /dev/tty on Rakudo
open(f"{root}/lib/Terminal/UI/Input.rakumod", 'w').write(open(f"{here}/Input.rakumod").read())
print("replaced lib/Terminal/UI/Input.rakumod")
