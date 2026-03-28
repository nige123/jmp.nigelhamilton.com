use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::Hit;

plan 6;

class DummyEditor {
    method edit (|) { }
}

my $sample-hit = JMP::File::Hit.new(
    relative-path => 't/data/1.txt',
    absolute-path => 't/data/1.txt'.IO.absolute,
    line-number => 3,
);

my $ui = JMP::UI.new(
    title => 'jmp to test',
    editor => DummyEditor.new,
    hits => [$sample-hit],
);

is-deeply(
    $ui.pane-heights-for-rows(30),
    [12, 17, 1],
    'top pane uses 12 lines, preview uses remaining, footer is 1 line'
);

is-deeply(
    $ui.pane-heights-for-rows(10),
    [8, 1, 1],
    'small terminals reserve preview and footer panes'
);

is(
    $ui.clamp-preview-line(0, 10),
    1,
    'preview line clamp floors to line 1'
);

is(
    $ui.clamp-preview-line(11, 10),
    10,
    'preview line clamp caps at the last line'
);

is(
    $ui.clamp-preview-line(4, 10),
    4,
    'preview line clamp keeps in-range lines unchanged'
);

is(
    $ui.clamp-preview-line(5, 0),
    1,
    'preview line clamp handles empty files'
);