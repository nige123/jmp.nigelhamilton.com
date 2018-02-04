
use JMP::System;
use JMP::Template;

# simple config file handling
class JMP::Config {

    has $.config-file;
    has %!fields;

    # get a simple value for a config field
    multi method get ($key) {

        die "Key $key does not exist in config file. Please add a value for $key to $.config-file"
            unless %!fields{$key}:exists;
        return %!fields{$key};

    }

    # get a config template value and render params into it
    multi method get ($key, %params) {
        my $value = $.get($key);
        return JMP::Template.new.render($value, %params);
    }

    # a helper sub called at object BUILD time
    submethod parse-config-file {

        my %fields;
        for $!config-file.IO.lines {

            # skip comments
            next if .starts-with('#');

            # config_keys.CAN.look-like.this
            # ^ $ - mark the start an end of line
            next unless /^ (.*?) '=' (.*?) $/;

            # save the key and value in config
            # $0 and $1 refer to the match objects in the regex
            # ~$0 stringifies the match object 
            # trim removes leading and trailing whitespace
            %fields{~$0.trim} = ~$1.trim;

        }
        return %fields;
    }

    # set up the user with a default config
    # this is a helper sub called at object BUILD time
    submethod populate-default-config-file {

        # populate the default config file
        # HEREdocs can be indented! The CONFIG end marker provides the 
        # indentation level 
        # .IO provides simple methods for slurping/spurting files to disk
        $!config-file.IO.spurt(q:to"CONFIG");
        
        #--------------------------------------------------------------------
        # uncomment or add your favourite text editor
        #--------------------------------------------------------------------
        
        editor.command.template   = nano +[-line-number-] "[-filename-]"
        
        # atom has Perl 6 syntax highlighting and other plugins for Perl 6
        # editor.command.template   = atom [-filename-]:[-line-number-] &
        
        # editor.command.template   = code -g [-filename-]:[-line-number-] &
        
        # editor.command.template   = subl [-filename-]:[-line-number-] &
        # editor.command.template   = emacs +[-line-number-]
        # editor.command.template   = vim +[-line-number-] [-filename-]
        
        #--------------------------------------------------------------------
        # uncomment or add your preferred code searching tool (below)
        #--------------------------------------------------------------------
        
        # classic recursive grep
        find.command.template       = grep -rHn '[-search-terms-]'
        
        # ag - the silver searcher for generic fast file searching
        # find.command.template     = ag --nogroup '[-search-terms-]'
        
        # git grep - for fast search of git repositories
        # find.command.template     = git grep --full-name --untracked --text --line-number -e '[-search-terms-]'
        
        # App::Ack - Perl-powered improvement to grep
        # find.command.template     = ack --nogroup '[-search-terms-]'
        
        CONFIG

    }

    submethod BUILD {

        $!config-file = $*HOME.add('.jmp').path;

        # .IO is handy for IO operations
        # populate the config if the file does not exist 
        self.populate-default-config-file 
            unless $!config-file.IO.e;

        # to a private hash variable %! 
        %!fields = self.parse-config-file;

    }
}

