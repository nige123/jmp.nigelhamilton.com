
use JMP::File::Hit;
use JMP::File::HitLater;

#| find jmp hits in your workflow
class JMP::Finder {

    has $.config;

    #| go to a specific line number in a file
    method find-line-in-file ($filename, $line-number) {

        return JMP::File::Hit.new(
                    relative-path   => $filename,
                    absolute-path   => $filename.IO.absolute, 
                    line-number     => $line-number, 
                );

    }

    #| look for the first matching line in a file
    method find-matching-line-in-file ($filename, $searchterms) {

        my $hit = JMP::File::Hit.new(
                    relative-path   => $filename, 
                    absolute-path   => $filename.IO.absolute, 
                    line-number     => 1, 
                );

        my $first-matching-line = 0;

        # look through the file for matching lines        
        for $filename.IO.lines -> $line {
            $first-matching-line++;
            next unless $line.contains($searchterms);
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

        for qqx{$find-command}.lines -> $line {

            my ($file-path, $line-number, $matching-text) = $line.split(':', 3);
                    
            next without $file-path and $line-number;

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

    #| find matching lines
    method find-files-in-command-output ($command) {

        # execute the command
        my $shell-cmd = shell $command, :out, :err;

        # join STDOUT and STDERR
        my $result = join("\n", $shell-cmd.out.slurp, $shell-cmd.err.slurp);

        # don't actually look for filenames just yet
        # do that lazily on demand by the user
        return $result.lines.map({ 
                    JMP::File::HitLater.new(text-to-match => $_) 
                });

    }

}
