
class JMP::Hit {

    has $.context;
    has $.file-path;
    has $.line-number = 1;
        
    method render {
        return $!file-path without $!context;
        my $context = $!context.subst("\t", ' ' x 4, :g);
        return '    (' ~ $!line-number ~ ') ' ~ $context;
    }
}
  
