use v6;
use lib 'lib';

use Test;
use JMP::Version;

plan 2;

my $repo-root = $*PROGRAM.parent.parent;

# JMP_TEST_BIN points at a compiled jmp; otherwise run bin/jmp with this compiler
my @command = %*ENV<JMP_TEST_BIN>
    ?? (%*ENV<JMP_TEST_BIN>,)
    !! ($*EXECUTABLE.Str, "-I{$repo-root.child('lib')}", $repo-root.child('bin/jmp').Str);
my $proc = run(|@command, 'version', :out, :err);

my $stdout = $proc.out.slurp-rest.chomp;
my $stderr = $proc.err.slurp-rest.chomp;

is $proc.exitcode, 0, 'jmp version exits successfully';
is $stdout, 'jmp - version ' ~ JMP::Version::VERSION, 'jmp version reports the current shared version';