# jmp.nigelhamilton.com

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


![](images/demo.gif?raw=true)
