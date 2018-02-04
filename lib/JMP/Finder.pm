use JMP::Finder::Hit;

class JMP::Finder {
   
    has $.config;

    method find-in-files ($search-terms) {
        
        my $find-command = $!config.get('find.command.template', { :$search-terms });

        # finish if nothing found?    
        return unless my $search-results = qqx{$find-command};

        my @hits;

        for $search-results.lines -> $line {

            my ($file-path, $line-number, $context) = $line.split(':', 3);
            @hits.push(JMP::Finder::Hit.new(:$file-path, :$line-number, :$context));

        }
        return @hits;
    }
}

