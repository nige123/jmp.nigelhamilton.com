use v6;
use lib 'lib';

use Test;
use JMP::Config;
use JMP::Editor;
use JMP::Memory;

plan 6;

my $test-home = $*TMPDIR.add("jmp-config-test-$*PID");
$test-home.mkdir unless $test-home.e;
temp $*HOME = $test-home;

# the default config: an unquoted editor template, quoted by the editor itself
my $default = JMP::Config.new;
is $default.get('editor.command.template', { filename => '/tmp/test.go', line-number => 42 }),
    'nano +42 /tmp/test.go', 'default editor template carries no quotes';

my $editor = JMP::Editor.new(config => $default, memory => JMP::Memory.new);
ok $editor.can('edit-at-line'), 'editor quotes the filename itself';

# a config with quoted values and an indented comment
$test-home.add('.jmp').spurt(q:to/CONFIG/);
    # a comment
        # an indented comment: editor.command.template = ignored
    editor.command.template = "nano +[-line-number-] [-filename-]"
    find.command.template = "rg --line-number '[-search-terms-]'"
    locate.command.template = "locate '[-search-terms-]'"
    CONFIG

my $config = JMP::Config.new;
is $config.get('editor.command.template', { filename => '/tmp/test.go', line-number => 42 }),
    'nano +42 /tmp/test.go', 'double quotes are stripped from the editor template';
is $config.get('find.command.template', { search-terms => 'TODO' }),
    "rg --line-number 'TODO'", 'double quotes are stripped from the find template';
is $config.get('locate.command.template', { search-terms => 'config.go' }),
    "locate 'config.go'", 'double quotes are stripped from the locate template';

throws-like { $config.get('browser.command.template') }, Exception,
    message => /^ 'key browser.command.template does not exist' /,
    'a missing key names itself';

unlink $test-home.add('.jmp');
rmdir $test-home;
