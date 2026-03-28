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
    line-number => 3,
);

my $ui = JMP::UI.new(
    title => 'jmp to test',
    editor => DummyEditor.new,
    hits => [$sample-hit],
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