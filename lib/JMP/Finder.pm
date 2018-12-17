
use JMP::File::Hit;
use JMP::File::HitLater;

#| find jmp hits in your workflow
class JMP::Finder {

    has $.config;

    #| search through multiple files
    method find-in-files ($search-terms) {
        
        # search through multiple files
        my $find-command = $!config.get('find.command.template', { :$search-terms });

        my @hits;

        my $previous-file = '';

        for qqx{$find-command}.lines -> $line {

            my ($file-path, $line-number, $context) = $line.split(':', 3);

            next without $file-path and $line-number;
                    
            if ($file-path ne $previous-file) {
                @hits.push(JMP::File::Hit.new(:$file-path, context => $file-path));
                $previous-file = $file-path;
            }                
            # show the line number in the context
            @hits.push(JMP::File::Hit.new(
                        :$file-path, 
                        :$line-number, 
                        context => '    (' ~ $line-number ~ ') ' ~ $context
                      ));
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
        return $result.lines.map({ JMP::File::HitLater.new(context => $_) });

    }

}
