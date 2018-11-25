
use JMP::Hit;

class JMP::File {
   
    has $.config;

    method find-matching-filenames ($search-terms) {
        
        my $file-command = $!config.get('file.command.template', { :$search-terms });
        
        my @hits = qqx{$file-command}.lines.map({ JMP::Hit.new(file-path => $_) });
       
        return @hits;
    }
}

