use JMP::Hit;

class JMP::Find {
   
    has $.config;

    method find-in-files ($search-terms) {
        
        my $find-command = $!config.get('find.command.template', { :$search-terms });

        my @hits;

        my $previous-file = '';

        for qqx{$find-command}.lines -> $line {
            my ($file-path, $line-number, $context) = $line.split(':', 3);
        
            if ($file-path ne $previous-file) {
                @hits.push(JMP::Hit.new(:$file-path));
                $previous-file = $file-path;
            }                
            @hits.push(JMP::Hit.new(:$file-path, :$line-number, :$context));
        }

        return @hits;
    }
}

