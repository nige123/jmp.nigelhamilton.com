use v6;
use lib 'lib';

use Test;
use JMP::Version;

plan 11;

my $repo-root = $*PROGRAM.parent.parent;

# JMP_TEST_BIN points at a compiled jmp; otherwise run bin/jmp with this compiler
sub jmp (*@args) {
    my @command = %*ENV<JMP_TEST_BIN>
        ?? (%*ENV<JMP_TEST_BIN>,)
        !! ($*EXECUTABLE.Str, "-I{$repo-root.child('lib')}", $repo-root.child('bin/jmp').Str);
    my $proc = run |@command, |@args, :out, :err;
    my $out = $proc.out.slurp(:close).chomp;
    my $err = $proc.err.slurp(:close).chomp;
    return ($proc.exitcode, $out, $err);
}

my ($code, $out, $err) = jmp('to');
is $code, 1, 'jmp to without a filename fails';
is $err, 'jmp to requires a filename', 'jmp to names what is missing';

($code, $out, $err) = jmp('edit');
is $code, 1, 'jmp edit without a filename fails';
is $err, 'edit requires at least a filename', 'jmp edit names what is missing';

($code, $out, $err) = jmp('back', 'lots');
is $code, 1, 'jmp back with a bad count fails';
is $err, 'invalid count for back: lots', 'jmp back names the bad count';

($code, $out, $err) = jmp('version', 'extra', 'args');
is $code, 0, 'jmp version ignores extra arguments';
is $out, 'jmp - version ' ~ JMP::Version::VERSION, 'jmp version still reports the version';

($code, $out, $err) = jmp('help', 'extra');
is $code, 0, 'jmp help ignores extra arguments';
ok $out.contains('jmp - jump to files in your workflow'), 'jmp help still prints the usage';

($code, $out, $err) = jmp('help');
ok $out.contains("jmp to <filename>"), 'usage documents jmp to';
