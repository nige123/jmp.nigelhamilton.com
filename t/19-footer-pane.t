use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::Hit;

plan 20;

class DummyEditor {
    method edit (|) { }
}

sub hit (Str $name) {
    JMP::File::Hit.new(relative-path => $name, absolute-path => $name.IO.absolute, line-number => 1);
}

my $empty = JMP::UI.new(title => 'jmp', editor => DummyEditor.new, hits => []);
my $five  = JMP::UI.new(title => 'jmp', editor => DummyEditor.new, hits => [<a b c d e>.map(&hit)]);

# pane heights: results take 35% of the terminal, each pane keeps a row
is-deeply $five.pane-heights(24), (8, 8),   'pane heights for 24 rows';
is-deeply $five.pane-heights(40), (14, 18), 'pane heights for 40 rows';
is-deeply $five.pane-heights(8),  (1, 1),   'pane heights guardrails for 8 rows';

# cursor counter in the results pane
is $empty.cursor-position-text(focus => 'results', selected-index => 0), '0/0', 'empty results count 0/0';
is $five.cursor-position-text(focus => 'results', selected-index => 0),  '1/5', 'start of results';
is $five.cursor-position-text(focus => 'results', selected-index => 2),  '3/5', 'middle of results';
is $five.cursor-position-text(focus => 'results', selected-index => 4),  '5/5', 'end of results';
is $five.cursor-position-text(focus => 'results', selected-index => 9),  '5/5', 'results index is clamped';

# cursor counter in the preview pane is relative to the loaded window
is $five.cursor-position-text(focus => 'preview', preview-index => 0,  preview-count => 10), '1/10',  'first preview line';
is $five.cursor-position-text(focus => 'preview', preview-index => 6,  preview-count => 10), '7/10',  'middle preview line';
is $five.cursor-position-text(focus => 'preview', preview-index => 23, preview-count => 50), '24/50', 'window at 100, line 123 counts 24/50';
is $five.cursor-position-text(focus => 'preview', preview-index => 0,  preview-count => 0),  '0/0',   'empty preview';

# footer: counter left, actions centred, version right
my $wide = $five.render-footer-line('1/5', 'actions', 'v1.0', 40);
is $wide.chars, 40,                     'wide footer fills the width';
ok $wide.starts-with('1/5'),            'wide footer has the counter at the left';
ok $wide.ends-with('v1.0'),             'wide footer has the version at the right';
ok $wide.contains(' actions '),         'wide footer has the actions in the middle';

my $narrow = $five.render-footer-line('12/345', 'actions', 'v69', 10);
is $narrow, '12/345 v69',               'narrow footer drops the actions first';

is $five.render-footer-line('1/5', 'actions', 'v69', 3), 'v69', 'tiny footer keeps only the version';

is $five.version-text, 'jmp v' ~ JMP::Version::VERSION, 'footer names the Raku version';

my $with-locate = JMP::UI.new(title => 'jmp', editor => DummyEditor.new, hits => [],
    searcher => -> $ { () }, outputer => -> $ { () }, locater => -> $ { () });
is $with-locate.footer-actions-text,
    '[↑][↓] [←][→] select  [i]n search  [o]n cmd  [t]o file  [h]elp  [q]uit',
    'footer lists every available action';
