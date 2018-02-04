use JMP::Config;

class JMP::Editor {
       
    has JMP::Config $.config;

    method edit-file ($filename, $line-number = 1) {   
        my $edit-file-command = $!config.get('editor.command.template', { :$filename, :$line-number });
        shell($edit-file-command);
    }

}

