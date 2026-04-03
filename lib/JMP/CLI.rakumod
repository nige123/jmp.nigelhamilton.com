use JMP;
use JMP::Version;
unit module JMP::CLI;

sub USAGE is export {

    say q:to"USAGE";

    jmp - jump to files in your workflow

    Usage:

        jmp                                         -- show most recent jmps
        jmp in '[<search-terms> ...]'               -- search in files for matching lines
        jmp to <filename>                           -- locate a file anywhere in the filesystem
        jmp to <filename> <line-number>             -- jump to a specific line in a file
        jmp on '<command ...>'                      -- jump on files in command output

        # jmp on examples:
        jmp on tail /some.log                       -- files mentioned in log files
        jmp on ls                                   -- files in a directory
        jmp on find .                               -- files returned from find
        jmp on git status                           -- files in git
        jmp on perl test.pl                         -- Perl output and errors
        jmp on raku test.raku                       -- Raku output and errors

        jmp config                                  -- edit ~/.jmp config
        jmp help                                    -- show this help

        jmp edit <filename> [<line-number>]         -- start editing at a line number
        jmp edit <filename> '[<search-terms> ...]'  -- start editing at a matching line

    USAGE

}

my $jmp = JMP.new(command => 'jmp ' ~ join(' ', @*ARGS));

#| show recent jmps
multi sub MAIN ('back', $last-n-jmps = 100) is export {
    $jmp.recent-jmps($last-n-jmps);
}

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

#| show the current version
multi sub MAIN ('version') is export {
    say 'jmp - version ' ~ JMP::Version::VERSION;
}

#| show this help
multi sub MAIN ('help') is export {
    USAGE();
}

#| jmp in - search in files for matching lines
multi sub MAIN ('in', *@search-terms) is export {
    my $search-terms = @search-terms.join(' ');
    $jmp.search-in-files($search-terms);
}

#| jmp to - locate a file, optionally at a line number
multi sub MAIN ('to', $filename, Int $line-number = 0) is export {
    if $line-number > 0 {
        $jmp.edit-file($filename, $line-number);
    }
    else {
        $jmp.locate-files($filename);
    }
}

#| jmp on files found in command output
multi sub MAIN ('on', *@command-args) is export {
    my $command = @command-args.join(' ');
    if $command {
        $jmp.find-files-in-command-output($command);
    }
    else {
        MAIN('back');
    }
}

#| backwards-compatible command-output mode without explicit `on`
multi sub MAIN (*@command-args) is export {
    my $command = @command-args.join(' ');
    if $command {
        $jmp.find-files-in-command-output($command);
    }
    else {
        # default to showing the jmp history
        MAIN('back');
    }
}
