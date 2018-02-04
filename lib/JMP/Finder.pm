use JMP::Finder::Hit;

class JMP::Finder {
   
    has $.config;

    method find-in-files ($search-terms) {
        
        my $find-command = $!config.get('find.command.template', { :$search-terms });

        my @hits;

        for qqx{$find-command}.lines -> $line {
            my ($file-path, $line-number, $context) = $line.split(':', 3);
	    next unless $context;
            @hits.push(JMP::Finder::Hit.new(:$file-path, :$line-number, :$context));
        }

        return @hits;
    }
}

