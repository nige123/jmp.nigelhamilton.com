use JMP;
unit module JMP::CLI;

sub USAGE is export {

    say q:to"USAGE";

    jmp - jump to files in your workflow

    Usage:
        
        jmp to '[<search-terms> ...]'               -- lines matching search terms in files

        # jmp on files in command output. For example:
        jmp locate README                           -- files in the filesystem
        jmp tail /some.log                          -- files mentioned in log files
        jmp ls                                      -- files in a directory
        jmp find .                                  -- files returned from the find command
        jmp git status                              -- files in git
        jmp perl test.pl                            -- Perl output and errors
        jmp perl6 test.pl                           -- Perl 6 output and errors

        jmp config                                  -- edit ~/.jmp config to set the editor 
                                                    -- and search commands 

        jmp edit <filename> [<line-number>]         -- start editing at a line number
        jmp edit <filename> '[<search-terms> ...]'  -- start editing at a matching line

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
    my $search-terms = @search-terms.join(' ');
    $jmp.edit-file-at-matching-line($filename, $search-terms);
}

#| show this help
multi sub MAIN ('help') is export {
    USAGE();
}

#| jmp to matching lines in files
multi sub MAIN ('to', *@search-terms) is export {
    my $search-terms = @search-terms.join(' ');
    $jmp.search-in-files('jmp to ' ~ $search-terms, $search-terms);
}

#| jmp on files found in command output
multi sub MAIN (*@command-args) is export {
    my $command = @command-args.join(' ');
    return USAGE() unless $command;
    $jmp.find-files-in-command-output('jmp ' ~ $command, $command);
}
