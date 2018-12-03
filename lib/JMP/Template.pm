#!/usr/bin/env perl6

#| simple Template engine
class JMP::Template {
    method render (Str $string is copy, %params) {
        # globally substitute tokens found in the string for values from the params hash
        $string ~~ s:g/'[-' (<[a..z-]>+) '-]'/{ %params{$0} }/;
        return $string;
    }
}
