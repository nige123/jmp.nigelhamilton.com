use v6;
use lib 'lib';

use Test;
use JMP::UI;
use JMP::File::HitLater;

plan 7;

class DummyEditor {
    method edit (|) { }
}

class FakePane {
    has @.lines is rw;
    has Bool $.selected is rw = False;

    method clear { @!lines = (); }
    method put ($line, *%_) { @!lines.push($line); }
    method select-first { $!selected = True; }
}

my $sample-hit = JMP::File::HitLater.new(text-to-match => 'initial line');
my $pane = FakePane.new;

my $ui-without-output = JMP::UI.new(
    title => 'jmp test',
    editor => DummyEditor.new,
    hits => [$sample-hit],
);

ok(
    !$ui-without-output.load-command-output('tail -n 10 /tmp/file.log', $pane),
    'load-command-output returns False when output callback is not defined'
);

my Str $seen-search = '';
my Str $seen-command = '';

my $ui = JMP::UI.new(
    title => 'jmp test',
    editor => DummyEditor.new,
    hits => [$sample-hit],
    searcher => -> $terms {
        $seen-search = $terms;
        [JMP::File::HitLater.new(text-to-match => "search:$terms")]
    },
    outputer => -> $command {
        $seen-command = $command;
        [
            JMP::File::HitLater.new(text-to-match => "out:$command"),
            JMP::File::HitLater.new(text-to-match => 'stderr: warning at t/data/1.txt line 1'),
        ]
    },
);

ok(
    !$ui.load-command-output('   ', $pane),
    'load-command-output returns False for blank commands'
);

ok(
    $ui.load-command-output('  tail -n 1000 /tmp/file.log  ', $pane),
    'load-command-output accepts non-empty command text'
);

is(
    $seen-command,
    'tail -n 1000 /tmp/file.log',
    'output callback receives trimmed command text'
);

is(
    $ui.title,
    'jmp on tail -n 1000 /tmp/file.log',
    'title is updated to jmp on <command>'
);

is(
    $ui.hits.elems,
    2,
    'hits are replaced with command output lines'
);

ok(
    $ui.load-search-results('needle', $pane) && $seen-search eq 'needle',
    'search path still works alongside output path'
);
