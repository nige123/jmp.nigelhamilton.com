use v6;
use lib 'lib';

use Test;
use JSON::Tiny;
use JMP::Memory;
use JMP::File::Hit;

plan 3;

# keep the test away from the real ~/.jmp.hist
my $*HOME = $*TMPDIR.add('jmp-history-cap-test-' ~ $*PID);
$*HOME.mkdir;

my $memory = JMP::Memory.new;
is $memory.max-entries, 500, 'history is capped at the last 500 entries';

# each save records two entries (the command and the destination),
# so 300 saves overflow a 500-entry cap
for 1..300 -> $n {
    my $hit = JMP::File::Hit.new(
        line-number   => $n,
        relative-path => "file-$n.txt",
        absolute-path => "/tmp/file-$n.txt",
        matching-text => "match $n",
    );
    $memory.save("jmp in match-$n", $hit);
}

my $history = from-json($*HOME.add('.jmp.hist').IO.slurp);
is $history.elems, 500, 'history file holds at most 500 entries';

my $fresh = JMP::Memory.new;
is $fresh.get-recent-jmps(500).elems, 500,
    'a fresh Memory replays up to 500 remembered entries';

unlink $*HOME.add('.jmp.hist');
rmdir $*HOME;
