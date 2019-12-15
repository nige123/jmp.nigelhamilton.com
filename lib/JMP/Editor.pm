use JMP::Config;
use JMP::Memory;

#| open files in a configured $EDITOR
class JMP::Editor {

    has JMP::Config $.config;
    has JMP::Memory $.memory;

    #| following a jmp hit, open at a file location and remember the action 
    method edit ($jmp-command, JMP::File::Hit $hit) {
        
        return without $hit.file-path;
        self.edit-at-line($hit.file-path, $hit.line-number);
        $!memory.save($jmp-command, $hit);

    }

    #| call a configured $EDITOR to open at a specfic line
    method edit-at-line ($filename, $line-number = 1) {

        # render $EDITOR command template - found in the config file
        my $edit-file-command = $!config.get('editor.command.template', { :$filename, :$line-number });
        shell($edit-file-command);

    }

    #| call a configured $EDITOR to open a file
    method edit-file ($filename) {
        self.edit-at-line($filename, 1);
    }

}

