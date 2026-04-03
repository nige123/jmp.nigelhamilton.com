
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
        # Editor — uncomment or add your favourite text editor
        #--------------------------------------------------------------------

        # nano — simple terminal editor (Linux, macOS, Windows/WSL)
        editor.command.template   = nano +[-line-number-] "[-filename-]"

        # VS Code — popular cross-platform editor (Linux, macOS, Windows)
        # editor.command.template   = code -g [-filename-]:[-line-number-] &

        # Vim — ubiquitous terminal editor (Linux, macOS, Windows)
        # editor.command.template   = vim +[-line-number-] [-filename-]

        # Neovim — modern Vim fork (Linux, macOS, Windows)
        # editor.command.template   = nvim +[-line-number-] [-filename-]

        # Emacs — extensible editor (Linux, macOS, Windows)
        # editor.command.template   = emacs +[-line-number-] [-filename-]

        # Sublime Text — fast GUI editor (Linux, macOS, Windows)
        # editor.command.template   = subl [-filename-]:[-line-number-] &

        # Helix — post-modern terminal editor (Linux, macOS, Windows)
        # editor.command.template   = hx [-filename-]:[-line-number-]

        # Micro — intuitive terminal editor (Linux, macOS, Windows)
        # editor.command.template   = micro +[-line-number-] [-filename-]

        # Atom — hackable editor (Linux, macOS, Windows) [discontinued but still used]
        # editor.command.template   = atom [-filename-]:[-line-number-] &

        #--------------------------------------------------------------------
        # Search — uncomment or add your preferred code searching tool
        # Used by: jmp in <search-terms>
        #--------------------------------------------------------------------

        # ripgrep — fast recursive search (Linux, macOS, Windows)
        find.command.template       = rg --line-number --with-filename --no-heading --color never '[-search-terms-]'

        # ag — the silver searcher (Linux, macOS, Windows)
        # find.command.template     = ag --nogroup '[-search-terms-]'

        # git grep — search within git repositories (any platform with git)
        # find.command.template     = git grep --full-name --untracked --text --line-number -e '[-search-terms-]'

        # ack — Perl-powered grep alternative (Linux, macOS, Windows)
        # find.command.template     = ack --nogroup '[-search-terms-]'

        # grep — universal fallback (Linux, macOS)
        # find.command.template     = grep -rn '[-search-terms-]' .

        #--------------------------------------------------------------------
        # Locate — uncomment or add your preferred file locating tool
        # Used by: jmp to <filename>
        #--------------------------------------------------------------------

        # locate — fast indexed file search (Linux, macOS with findutils)
        locate.command.template     = locate '[-search-terms-]'

        # plocate — fast modern replacement for locate (newer Linux distros)
        # locate.command.template   = plocate '[-search-terms-]'

        # mlocate — common on Ubuntu/Debian
        # locate.command.template   = mlocate '[-search-terms-]'

        # fd — simple, fast find alternative (Linux, macOS, Windows)
        # locate.command.template   = fd --type f '[-search-terms-]'

        # find — universal fallback, no index needed (Linux, macOS)
        # locate.command.template   = find / -name '*[-search-terms-]*' -type f 2>/dev/null

        # mdfind — macOS Spotlight search from terminal
        # locate.command.template   = mdfind -name '[-search-terms-]'

        # everything — voidtools Everything CLI for Windows (very fast)
        # locate.command.template   = es -name '[-search-terms-]'

        # where — Windows built-in file search
        # locate.command.template   = where /r \\ [-search-terms-]

        #--------------------------------------------------------------------
        # Browser — uncomment or add your preferred browser launch command
        #--------------------------------------------------------------------

        # xdg-open — open URLs in default browser (Linux)
        browser.command.template       = xdg-open '[-url-]'

        # open — open URLs in default browser (macOS)
        # browser.command.template   = open '[-url-]'

        # start — open URLs in default browser (Windows)
        # browser.command.template   = start '[-url-]'

        # elinks — terminal-based browser (Linux, macOS)
        # browser.command.template   = elinks '[-url-]'

        # wslview — open URLs from WSL in Windows browser
        # browser.command.template   = wslview '[-url-]'

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

