use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::Hit;

plan 4;

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

# Test 1: pane-heights-for-rows returns 3 panes including footer
is(
    $ui.pane-heights-for-rows(30).elems,
    3,
    'pane-heights-for-rows returns 3 pane heights (results, preview, footer)'
);

# Test 2: footer pane is always 1 line
is(
    $ui.pane-heights-for-rows(30)[2],
    1,
    'footer pane is 1 line on normal terminal sizes'
);

# Test 3: footer pane is 1 line on small terminals too
is(
    $ui.pane-heights-for-rows(10)[2],
    1,
    'footer pane remains 1 line even on tiny terminals'
);

# Test 4: footer pane is still 1 line on large terminals
is(
    $ui.pane-heights-for-rows(100)[2],
    1,
    'footer pane never expands beyond 1 line'
);
