
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
use JMP::File;
use JMP::Find;
use JMP::UI;

has JMP::Config $.config;
has JMP::Editor $.editor;
has JMP::Find   $.find;
has JMP::File   $.file;

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

method find-matching-filenames ($search-terms) {

    # finish if nothing found?    
    my @hits = self.file.find-matching-filenames($search-terms);

    return unless @hits.elems;

    # prepare to show a screenful of results
    my $screen = JMP::UI.new(
        title => 'jmp file ' ~ $search-terms, 
        :@hits,
        :$!editor,
    );
    $screen.display;

}

method search-in-files ($search-terms) {

    # finish if nothing found?    
    my @hits = self.find.find-in-files($search-terms);

    return unless @hits.elems;

    # prepare to show a screenful of results
    my $screen = JMP::UI.new(
        title => 'jmp find ' ~ $search-terms, 
        :@hits,
        :$!editor,
    );
    $screen.display;

}

submethod BUILD {
    $!config = JMP::Config.new;
    $!editor = JMP::Editor.new(:$!config);
    $!file   = JMP::File.new(:$!config);
    $!find   = JMP::Find.new(:$!config);
}
