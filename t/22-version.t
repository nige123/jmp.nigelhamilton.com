use v6;
use lib 'lib';

use Test;
use JMP::Version;

plan 2;

my $repo-root = $*PROGRAM.parent.parent;
my $proc = run(
    'raku',
    "-I{$repo-root.child('lib')}",
    $repo-root.child('bin/jmp').Str,
    'version',
    :out,
    :err,
);

my $stdout = $proc.out.slurp-rest.chomp;
my $stderr = $proc.err.slurp-rest.chomp;

is $proc.exitcode, 0, 'jmp version exits successfully';
is $stdout, 'jmp - version ' ~ JMP::Version::VERSION, 'jmp version reports the current shared version';