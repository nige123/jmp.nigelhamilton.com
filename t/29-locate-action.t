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

my $without-locater = JMP::UI.new(title => 'jmp test', editor => DummyEditor.new, hits => [$sample-hit]);
nok $without-locater.load-locate-results('config.go', $pane), 'no locater, no locate results';

my $seen = '';
my $ui = JMP::UI.new(
    title   => 'jmp test',
    editor  => DummyEditor.new,
    hits    => [$sample-hit],
    locater => -> $filename {
        $seen = $filename;
        [ JMP::File::HitLater.new(text-to-match => "/tmp/$filename"),
          JMP::File::HitLater.new(text-to-match => "/var/$filename") ]
    },
);

nok $ui.load-locate-results('   ', $pane), 'a blank filename is ignored';
ok  $ui.load-locate-results('  config.go  ', $pane), 'locate runs for a filename';
is  $seen, 'config.go', 'the filename is trimmed';
is  $ui.title, 'jmp to config.go', 'the title becomes jmp to <filename>';
is  $ui.hits.elems, 2, 'the located files replace the results';
is-deeply $pane.lines, ['/tmp/config.go', '/var/config.go'], 'the results pane shows the located files';
