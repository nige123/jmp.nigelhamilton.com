use JMP::File::Hit;

class JMP::File::HitLater is JMP::File::Hit {

    method edit-file ($editor) {

        # jmp straight to the editor if the file-path is already set                     
        return $editor.edit-file(self.file-path, self.line-number)    
            with self.file-path;

        # look for something to edit
        self.find-file-path;

        return without self.file-path;

        # we found something to edit - call the editor
        return $editor.edit-file(self.file-path, self.line-number);
            
    }

    submethod find-file-path {
    
        given self.context {

            # matches Perl 5 error output (e.g., at SomePerl.pl line 12)
            when /at \s (\S+) \s line \s (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }
            
            # matches Perl 6 error output (e.g., at SomePerl6.p6:12)
            when /at \s (<-[\s:]>+) ':' (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }           

            # matches Perl 6 error output (e.g., SomePerl6.p6 (Some::Perl6):12)
            when /at \s (<-[\s:]>+) '(' \S+ ')' ':' (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }           

            # more file finding patterns HERE - PR's welcome?

            # go through each token
            default {
                for self.context.words -> $token {
                    # keep trying to set the file path
                    proceed if self.found-file-path($token);                    
                }
            }
        }
    }

    submethod found-file-path ($file-path, $line-number = 1) {
        
        # look for live files
        return False unless $file-path.IO.f and $file-path.IO.e;
        self.file-path = $file-path;
        self.line-number = $line-number;
        return True;

    }

    submethod TWEAK {

        # https://rosettacode.org/wiki/Strip_control_codes_and_extended_characters_from_a_string#Perl_6
        self.context = self.context.subst(/<:Cc>/, '', :g);

        # strip out any colour codes in the output
        self.context = self.context.subst(/'[' <[0..9;]>* 'm'/, '', :g);

    }

}
