
use JSON::Tiny;
use JMP::Memory::Command;
use JMP::Memory::Hit;

# keep a file-based record of the searches and jmps
class JMP::Memory {

    has $.max-entries = 100;  # keep a record of the last 100 jmps
    has $!file;
    has @!latest-jmps;         

    #| get a list of the most recent JMP::File::Hits
    method get-recent-jmps ($last-n-jmps) {
        # return a list of JMP::File::Hits 
        my @recent-jmps;
        for @!latest-jmps.head($last-n-jmps) -> %hit {
            my $hit = %hit<jmp-command>:exists  
                    ?? JMP::Memory::Command.new(|%hit)
                    !! JMP::Memory::Hit.new(|%hit);
            @recent-jmps.push($hit);
        }
        return @recent-jmps;
    }

    #| write the memory file 
    method save ($jmp-command, $hit) {

        # for each incoming hit - we record two entries - the jmp command
        my %jmp-record = %( 
            current-directory   =>  $*CWD.path,
            jmp-command         =>  $jmp-command, 
        );

        # and the selected destination
        my %hit-record = %( 
            line-number         =>  $hit.line-number,
            relative-path       =>  $hit.relative-path,
            absolute-path       =>  $hit.absolute-path,
            matching-text       =>  $hit.matching-text,
        );

        @!latest-jmps.unshift(%hit-record);
        @!latest-jmps.unshift(%jmp-record);

        my @hits = @!latest-jmps;

        @!latest-jmps = @hits.head($!max-entries);    

        # dump to disk
        $!file.IO.spurt(to-json(@!latest-jmps));        
    }

    submethod TWEAK {

        $!file = $*HOME.add('.jmp.hist').path;
        return unless $!file.IO.e;
        return without my $history = from-json($!file.IO.slurp);
        @!latest-jmps = $history.List;
     
    }
}

sub MAIN {
    
    my $m = JMP::Memory.new;
    $m.get-recent-jmps(100);

}
