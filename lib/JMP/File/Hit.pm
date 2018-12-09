
class JMP::File::Hit {

    has $.context     is rw;
    has $.file-path   is rw;
    has $.line-number is rw = 1;

    method edit-file ($editor) {
        $editor.edit-file($!file-path, $!line-number);
    }

    method render {
        return $!context;
    }

    submethod TWEAK {
    
        # substitute tabs for 4 spaces
        $!context = $!context.subst("\t", ' ' x 4, :g);

    }
}
