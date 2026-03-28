use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::Hit;

plan 3;

class DummyEditor {
    method edit (|) { }
}

my $sample-hit = JMP::File::Hit.new(
    relative-path => 't/data/1.txt',
    absolute-path => 't/data/1.txt'.IO.absolute,
    line-number => 1,
);

my $ui = JMP::UI.new(
    title => 'jmp to test',
    editor => DummyEditor.new,
    hits => [$sample-hit],
);

# Terminal::UI fr => 1 now handles height distribution — no manual calculator needed.
ok $ui.defined, 'JMP::UI can be instantiated';
ok !$ui.can('pane-heights-for-rows'), 'pane heights delegated to Terminal::UI fr => 1 (no manual calculator)';
ok !$ui.can('detect-screen-rows'),    'screen row detection delegated to Terminal::UI (no manual detection)';

