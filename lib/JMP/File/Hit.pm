
class JMP::File::Hit {

    has $.matching-text     is rw = '';     # the line of text that was matched
    has $.relative-path     is rw;
    has $.absolute-path     is rw;
    has $.line-number       is rw = 1;

    method render {
        return '    (' ~ $!line-number ~ ') ' ~ $!matching-text
            if $!matching-text.chars > 0;
        return $!relative-path;
    }
    
    method file-exists {
        return $!absolute-path 
           and $!absolute-path.IO.f 
           and $!absolute-path.IO.e;
    }

    submethod TWEAK {
        # substitute tabs for 4 spaces    
        $!matching-text = $!matching-text.subst("\t", ' ' x 4, :g);
    }
}
