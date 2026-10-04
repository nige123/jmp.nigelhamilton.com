use v6;
use lib 'lib';

use Test;
use JMP::File::HitLater;

plan 12;

my $file = 't/data/1.txt';

sub located (Str $text) {
    my $hit = JMP::File::HitLater.new(text-to-match => $text);
    $hit.find-file-path;
    return $hit;
}

my $perl = located("Died at $file line 3.");
is $perl.relative-path, $file, 'Perl output: file';
is $perl.line-number, 3,       'Perl output: line';
isa-ok $perl.relative-path, Str, 'file path is a plain string';
isa-ok $perl.line-number, Int,   'line number is a plain integer';

is located("  at $file:7").line-number, 7, 'Raku file:line output';
is located("  in sub foo at $file (Some::Module):9").line-number, 9, 'Raku file (Module):line output, with a space before the module';
is located("  at $file   (Some::Module)  line   11").line-number, 11, 'Raku file (Module) line N output, with flexible spacing';
is located("at $file line 0").line-number, 1, 'a line below 1 is clamped to 1';
is located("touched $file today").line-number, 1, 'a bare filename in the text is found at line 1';
nok located("nothing here").file-exists, 'no file, no hit';

my $tabbed = JMP::File::HitLater.new(text-to-match => "a\tb\x[01]c\e[31md\e[0m");
is $tabbed.render, "a\tbcd", 'control characters and colour codes are stripped, tabs kept';
is $tabbed.text-to-match.chars, 5, 'nothing else is lost';
