use JMP;
unit module JMP::CLI;

sub USAGE is export {

    say q:to"USAGE";

    jmp - search files and jump to matching lines in a text editor

    Usage:
        
        jmp config -- edit ~/.jmp config to set the editor and search commands 
        jmp edit <filename> [<line-number>] -- start editing at a line number
        jmp edit <filename> '[<search-terms> ...]' -- start editing at a matching line
        jmp file '[<search-terms> ...]' -- find matching filenames   
        jmp find '[<search-terms> ...]' -- find search terms within files    

    USAGE
}

my $jmp = JMP.new;

#| edit the ~/.jmp config to set the editor and search commands
multi sub MAIN ('config') is export { 
    $jmp.edit-config;
}

#| start editing at a line number
multi sub MAIN ('edit', $filename, Int $line-number = 0) is export {
    $jmp.edit-file($filename, $line-number);
}

#| starting editing at a matching line
multi sub MAIN ('edit', $filename, *@search-terms) is export {
    $jmp.edit-file-at-matching-line($filename, @search-terms.join(' '));
}

#| find search terms in files
multi sub MAIN ('find', *@search-terms) is export {
    $jmp.search-in-files(@search-terms.join(' '));
}

#| find matching file names
multi sub MAIN ('file', *@search-terms) is export {
    $jmp.find-matching-filenames(@search-terms.join(' '));
}
