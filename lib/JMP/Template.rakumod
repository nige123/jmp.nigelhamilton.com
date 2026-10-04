
#| simple Template engine
class JMP::Template {
    method render (Str $string is copy, %params) {
        # globally substitute [-name-] tokens for values from the params hash;
        # a token with no value is left as it is (same as go-jmp)
        $string ~~ s:g/'[-' (<[a..z-]>+) '-]'/{ my $key = ~$0; %params{$key}:exists ?? %params{$key} !! '[-' ~ $key ~ '-]' }/;
        return $string;
    }
}
