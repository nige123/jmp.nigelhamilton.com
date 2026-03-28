use JMP::Config;
use JMP::Memory;

#| open files in a configured $EDITOR
class JMP::Editor {

    has JMP::Config $.config;
    has JMP::Memory $.memory;

    #| following a jmp hit, open at a file location and remember the action 
    method edit ($jmp-command, JMP::File::Hit $hit) {
        
        return unless $hit.file-exists;
        self.edit-at-line($hit.absolute-path, $hit.line-number);
        $!memory.save($jmp-command, $hit);

    }

    #| call a configured $EDITOR to open at a specfic line
    method edit-at-line ($filename, $line-number = 1) {

        # render $EDITOR command template - found in the config file
        my $edit-file-command = $!config.get('editor.command.template', { :$filename, :$line-number });

        # Connect the editor explicitly to /dev/tty so it gets a proper
        # terminal regardless of how stdin/stdout are connected to jmp.
        my $tty = open('/dev/tty', :rw);
        shell($edit-file-command, :in($tty), :out($tty), :err($tty));
        $tty.close;

    }

    #| call a configured $EDITOR to open a file
    method edit-file ($filename) {
        self.edit-at-line($filename, 1);
    }

}

