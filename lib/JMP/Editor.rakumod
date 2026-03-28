use JMP::Config;
use JMP::Memory;

#| open files in a configured $EDITOR
class JMP::Editor {

    has JMP::Config $.config;
    has JMP::Memory $.memory;

    method !tokenize-command (Str $command) {
        my @tokens;
        my $current = '';
        my $quote = '';
        my $escaped = False;

        for $command.comb -> $char {
            if $escaped {
                $current ~= $char;
                $escaped = False;
                next;
            }

            if $char eq '\\' {
                $escaped = True;
                next;
            }

            if $quote ne '' {
                if $char eq $quote {
                    $quote = '';
                }
                else {
                    $current ~= $char;
                }
                next;
            }

            if $char eq '"' || $char eq "'" {
                $quote = $char;
                next;
            }

            if $char ~~ /\s/ {
                if $current.chars {
                    @tokens.push($current);
                    $current = '';
                }
                next;
            }

            $current ~= $char;
        }

        $current ~= '\\' if $escaped;

        die "Unterminated quote in editor.command.template: $command"
            if $quote ne '';

        @tokens.push($current) if $current.chars;

        # Legacy templates sometimes include '&' to background shell commands.
        # Strip it because we are intentionally launching without a shell.
        @tokens.pop if @tokens.elems && @tokens[*-1] eq '&';

        return @tokens;
    }

    method editor-command-args ($filename, $line-number = 1) {

        my $edit-file-command = $!config.get(
            'editor.command.template',
            { :$filename, :$line-number }
        );

        return self!tokenize-command($edit-file-command);
    }

    #| following a jmp hit, open at a file location and remember the action 
    method edit ($jmp-command, JMP::File::Hit $hit) {
        
        return unless $hit.file-exists;
        self.edit-at-line($hit.absolute-path, $hit.line-number);
        $!memory.save($jmp-command, $hit);

    }

    #| call a configured $EDITOR to open at a specfic line
    method edit-at-line ($filename, $line-number = 1) {

        # Launch the editor directly (no shell) to avoid TUI/editor interaction.
        my @editor-command = self.editor-command-args($filename, $line-number);
        die 'editor.command.template rendered to an empty command'
            unless @editor-command.elems;

        run |@editor-command, :in($*IN), :out($*OUT), :err($*ERR);

    }

    #| call a configured $EDITOR to open a file
    method edit-file ($filename) {
        self.edit-at-line($filename, 1);
    }

}

