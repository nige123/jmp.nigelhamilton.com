use JMP::File::Hit;

class JMP::File::HitLater is JMP::File::Hit {

    has $.text-to-match is rw;

    method find-file-path {

        return if self.file-exists;

        my $text = self.text-to-match;

        # matches Perl 5 error output (e.g., at SomePerl.pl line 12)
        if $text ~~ /at \s+ (\S+) \s+ 'line' \s+ (\d+)/ {
            return if self.found-file-path(~$0, +$1);
        }

        # matches Raku error output (e.g., at SomeRaku.raku:12)
        if $text ~~ /at \s+ (<-[\s:]>+) ':' (\d+)/ {
            return if self.found-file-path(~$0, +$1);
        }

        # matches Raku error output (e.g., at SomeRaku.raku (Some::Raku):12)
        if $text ~~ /at \s+ (<-[\s:]>+) \s* '(' \S+ ')' ':' (\d+)/ {
            return if self.found-file-path(~$0, +$1);
        }

        # matches Raku error output (e.g., at /Some/Module.rakumod (Some::Module) line 12)
        if $text ~~ /at \s+ (<-[\s:]>+) \s* '(' \S+ ')' \s+ 'line' \s+ (\d+)/ {
            return if self.found-file-path(~$0, +$1);
        }

        # more file finding patterns HERE for other languages - PR's welcome?

        # go through each token: the first existing file wins, at line 1
        for $text.words -> $token {
            return if self.found-file-path($token, 1);
        }
    }

    method render {
        return $!text-to-match;
    }

    submethod found-file-path (Str() $file-path, Int() $line-number = 1) {

        # look for live files only
        return False unless $file-path.IO.f and $file-path.IO.e;

        # capture the location; a line below 1 is clamped to 1
        self.relative-path  = $file-path;
        self.absolute-path  = $file-path.IO.absolute;
        self.line-number    = $line-number < 1 ?? 1 !! $line-number;
        self.matching-text  = self.text-to-match;
        
        return True;

    }

    submethod TWEAK {

        # strip control characters, keeping tabs and line ends
        # (comb/grep rather than a regex conjunction: it runs the same on Rakudo and Raku++)
        self.text-to-match = self.text-to-match.comb.grep({
            $_ eq "\t" | "\n" | "\r" or .uniprop ne 'Cc'
        }).join;

        # strip out any colour codes in the output
        self.text-to-match = self.text-to-match.subst(/'[' <[0..9;]>* 'm'/, '', :g);

    }

}
