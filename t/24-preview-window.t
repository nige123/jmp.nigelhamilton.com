use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::Hit;

plan 5;

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

is-deeply(
    [$ui.preview-window(0, 1)],
    [1, 1],
    'preview window handles empty files safely'
);

is-deeply(
    [$ui.preview-window(100, 20, 400)],
    [1, 100],
    'preview window includes full file when file is smaller than window'
);

is-deeply(
    [$ui.preview-window(1000, 25, 200)],
    [1, 200],
    'preview window anchors to file start for early target lines'
);

is-deeply(
    [$ui.preview-window(1000, 975, 200)],
    [801, 1000],
    'preview window anchors to file end for late target lines'
);

is-deeply(
    [$ui.preview-window(1000, 500, 200)],
    [400, 599],
    'preview window centers around the target for mid-file lines'
);
