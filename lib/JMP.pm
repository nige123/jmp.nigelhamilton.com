
#--------------------------------------------------------------------------------
#
# Nigel Hamilton (2016-Now) - Artistic Licence 2.0
#
# jmp - find matching files and jump into your $EDITOR
#
#--------------------------------------------------------------------------------

unit class JMP;

use JMP::Config;
use JMP::Editor;
use JMP::Finder;
use JMP::Screen;

has JMP::Config $.config;
has JMP::Editor $.editor;
has JMP::Finder $.finder;

method edit-config { 
    $!editor.edit-file($!config.config-file);   
}

method edit-file ($filename, $line-number = 1) {
    $!editor.edit-file($filename, $line-number);
}

method edit-file-at-matching-line ($filename, $search-terms) {
    my $current-line = 0;
    for $filename.IO.lines -> $line {
        $current-line++;
        if $line.contains($search-terms) {
            return $!editor.edit-file($filename, $current-line);
        }
    }
    # nothing matched - open at the first line        
    return $!editor.edit-file($filename, 1);    
}

method find ($search-terms) {

    # finish if nothing found?    
    my @hits = self.finder.find-in-files($search-terms);

    return unless @hits.elems;

    # prepare to show a screenful of results
    my $screen = JMP::Screen.new(title => 'jmp find ' ~ $search-terms);
    $screen.add-edit-actions($!editor, $search-terms, @hits);
    $screen.display-page(1);

}

submethod BUILD {
    $!config = JMP::Config.new;
    $!editor = JMP::Editor.new(:$!config);
    $!finder = JMP::Finder.new(:$!config);
}
