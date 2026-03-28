use v6;
use lib 'lib';

use Test;
use JMP::Config;
use JMP::Editor;
use JMP::File::Hit;
use JMP::Memory;

plan 3;

my $test-home = $*TMPDIR.add("jmp-editor-test-$*PID");
$test-home.mkdir unless $test-home.IO.e;

temp $*HOME = $test-home;

my $test-file = $*TMPDIR.add("editor-input-test-$*PID.txt");
$test-file.IO.spurt("line 1\nline 2\nline 3\n");

my $config = JMP::Config.new;
my $memory = JMP::Memory.new;
my $editor = JMP::Editor.new(:$config, :$memory);

ok($editor.defined, 'Editor instance created');
ok($config.defined, 'Config instance created');
ok($memory.defined, 'Memory instance created');

$test-file.IO.unlink if $test-file.IO.e;

