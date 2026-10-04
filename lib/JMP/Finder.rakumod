
use JMP::File::Hit;
use JMP::File::HitLater;

#| find jmp hits in your workflow
class JMP::Finder {

    has $.config;

    method !parse-find-output-line ($line) {
        return unless $line ~~ /^(.*) ':' (\d+) ':' (.*)$/;
        return (~$0, +$1, ~$2);
    }

    #| run a command and return its standard output lines; standard error is captured and discarded
    method !command-output-lines ($command) {
        my $proc = run '/bin/sh', '-c', $command, :out, :err;
        my @lines = $proc.out.lines(:enc('utf8-c8'));
        # drain stderr after stdout so the search tool cannot write over the UI
        $proc.err.slurp;
        return @lines;
    }

    #| go to a specific line number in a file
    method find-line-in-file ($filename, $line-number) {

        return JMP::File::Hit.new(
                    relative-path   => $filename,
                    absolute-path   => $filename.IO.absolute, 
                    line-number     => $line-number < 1 ?? 1 !! $line-number,
                );

    }

    #| look for the first matching line in a file
    method find-matching-line-in-file ($filename, $searchterms) {

        my $hit = JMP::File::Hit.new(
                    relative-path   => $filename, 
                    absolute-path   => $filename.IO.absolute, 
                    line-number     => 1, 
                );

        # a file that cannot be read still opens at line 1
        return $hit unless $filename.IO.f;

        my $first-matching-line = 0;

        # look through the file for matching lines        
        for $filename.IO.lines -> $line {
            $first-matching-line++;
            next unless $line.chomp.contains($searchterms);
            # found a matching line - remember it
            $hit.line-number = $first-matching-line;
            $hit.matching-text = $line;
            last;
        }

        return $hit;

    }

    #| search through multiple files
    method find-in-files ($search-terms) {

        # search through multiple files
        my $find-command = $!config.get('find.command.template', { :$search-terms });

        my @hits;

        my $previous-file = '';

        for self!command-output-lines($find-command) -> $line {

            my ($file-path, $line-number, $matching-text) = self!parse-find-output-line($line);
            next unless $file-path.defined;

            if ($file-path ne $previous-file) {
                @hits.push(
                    JMP::File::Hit.new(
                        relative-path => $file-path,
                        absolute-path => $file-path.IO.absolute,
                    )
                );
                $previous-file = $file-path;
            }
            # show the line number in the context
            @hits.push(
                JMP::File::Hit.new(
                    relative-path => $file-path,
                    absolute-path => $file-path.IO.absolute,
                    :$line-number,
                    :$matching-text,
                )
            );
        }
        return @hits;
    }

    #| locate files on the filesystem
    method find-files-on-filesystem ($search-terms) {

        my $locate-command = $!config.get('locate.command.template', { :$search-terms });

        return self!command-output-lines($locate-command).map({
                    JMP::File::HitLater.new(text-to-match => $_)
                }).Array;

    }

    #| find matching lines
    method find-files-in-command-output ($command) {

        # execute the command with STDOUT and STDERR interleaved as they happen
        my $proc = run '/bin/sh', '-c', $command, :out, :merge;
        my $result = $proc.out.slurp(:enc('utf8-c8'));

        # normalise line ends and drop the final newline
        $result = $result.subst("\r\n", "\n", :g);
        $result = $result.chop if $result.ends-with("\n");

        # don't actually look for filenames just yet
        # do that lazily on demand by the user
        return $result.split("\n").map({ 
                    JMP::File::HitLater.new(text-to-match => $_) 
                }).Array;

    }

}
