use v6;
use lib 'lib';

use Test;
use JMP::Config;
use JMP::Finder;

plan 8;

my $test-home = $*TMPDIR.add("jmp-config-test-$*PID");
$test-home.mkdir unless $test-home.IO.e;

temp $*HOME = $test-home;

my $config = JMP::Config.new;
my $find-template = $config.get('find.command.template');

is(
    $find-template,
    q[rg --line-number --with-filename --no-heading --color never '[-search-terms-]'],
    'default config uses ripgrep with stable file:line:text output'
);

my $rendered = $config.get('find.command.template', { 'search-terms' => 'needle' });
ok($rendered.starts-with('rg '), 'rendered search command uses rg');
like($rendered, /'--line-number'/, 'rendered search command keeps line numbers');
like($rendered, /'--with-filename'/, 'rendered search command keeps filenames');
like($rendered, /'--no-heading'/, 'rendered search command disables headings');
like($rendered, /'--color never'/, 'rendered search command disables ANSI color');

class FakeConfig {
    method get ($key, %params) {
        return q[printf '%s\n' 't/data/1.txt' '1:wrong-heading-style-match' 't/data/1.txt:1:the real match'];
    }
}

my @hits = JMP::Finder.new(config => FakeConfig.new).find-in-files('ignored');

is(@hits.elems, 2, 'finder ignores ripgrep heading-style lines without filenames');
is-deeply(
    @hits.map({ .relative-path, .line-number, .matching-text }).Array,
    [('t/data/1.txt', 1, ''), ('t/data/1.txt', 1, 'the real match')],
    'finder keeps only valid file:line:text results'
);