use JMP::File::Hit;

class JMP::File::HitLater is JMP::File::Hit {

    has $.text-to-match is rw;

    method find-file-path {

        return if self.file-exists;

        given self.text-to-match {

            # matches Perl 5 error output (e.g., at SomePerl.pl line 12)
            when /at \s (\S+) \s line \s (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }

            # matches Raku (Perl 6) error output (e.g., at SomePerl6.p6:12)
            when /at \s (<-[\s:]>+) ':' (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }

            # matches Raku (Perl 6) error output (e.g., SomePerl6.p6 (Some::Perl6):12)
            when /at \s (<-[\s:]>+) '(' \S+ ')' ':' (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }

            # matches Raku (Perl 6) error output (e.g., at /Some/Module.pm (Some::Module) line 12)
            when /at \s (<-[\s:]>+) '(' \S+ ') line ' (\d+)/ {
                proceed unless self.found-file-path($/[0], $/[1]);
            }           

            # more file finding patterns HERE for other languages - PR's welcome?

            # go through each token
            default {
                for self.text-to-match.words -> $token {
                    # keep trying to set the file path
                    proceed if self.found-file-path($token);
                }
            }
        }
    }

    method render {
        return $!text-to-match;
    }

    submethod found-file-path ($file-path, $line-number = 1) {

        # look for live files only
        return False unless $file-path.IO.f and $file-path.IO.e;

        # capture the location
        self.relative-path  = $file-path;
        self.absolute-path  = $file-path.IO.absolute;
        self.line-number    = $line-number;
        self.matching-text  = self.text-to-match;
        
        return True;

    }

    submethod TWEAK {

        # https://rosettacode.org/wiki/Strip_control_codes_and_extended_characters_from_a_string#Perl_6
        self.text-to-match = self.text-to-match.subst(/<:Cc>/, '', :g);

        # strip out any colour codes in the output
        self.text-to-match = self.text-to-match.subst(/'[' <[0..9;]>* 'm'/, '', :g);

    }

}
