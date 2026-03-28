# jmp.nigelhamilton.com

jmp - jump to files in your workflow

Usage:

    jmp                                         -- show most recent
    jmp to '[<search-terms> ...]'               -- lines matching search terms in files

    # jmp on files in command output. For example:
    jmp on locate README                        -- files in the filesystem
    jmp on tail /some.log                       -- files mentioned in log files
    jmp on ls                                   -- files in a directory
    jmp on find .                               -- files returned from the find command
    jmp on git status                           -- files in git
    jmp on perl test.pl                         -- Perl output and errors
    jmp on raku test.raku                       -- Raku output and errors

    jmp config                                  -- edit ~/.jmp config to set the editor
                                                -- and search commands
    jmp help                                    -- show this help

    jmp edit <filename> [<line-number>]         -- start editing at a line number
    jmp edit <filename> '[<search-terms> ...]'  -- start editing at a matching line


![](images/demo.gif?raw=true)
