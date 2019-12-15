
class JMP::File::Hit {

    has $.matching-text     is rw = '';     # the line of text that was matched
    has $.file-path         is rw;
    has $.full-path         is rw;
    has $.line-number       is rw = 1;

    method render {
        return '    (' ~ $!line-number ~ ') ' ~ $!matching-text
            if $!matching-text.chars > 0;
        return $!file-path;
    }

    submethod TWEAK {
        # substitute tabs for 4 spaces    
        $!matching-text = $!matching-text.subst("\t", ' ' x 4, :g);
        with $!file-path { 
            $!full-path     = $!file-path.IO.absolute;
        }
    }
}
