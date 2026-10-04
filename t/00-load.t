use v6;
use Test;

plan 12;

use-ok('JMP');
# Raku++ runs an imported MAIN inside use-ok's EVAL, which would start the UI
if $*RAKU.compiler.name eq 'Raku++' {
    skip 'Raku++ runs an imported MAIN inside use-ok', 1;
}
else {
    use-ok('JMP::CLI');
}
use-ok('JMP::Config');
use-ok('JMP::Editor');
use-ok('JMP::Finder');
use-ok('JMP::File::Hit');
use-ok('JMP::File::HitLater');
use-ok('JMP::Memory');
use-ok('JMP::Memory::Hit');
use-ok('JMP::Memory::Command');
use-ok('JMP::Template');
use-ok('JMP::UI');



