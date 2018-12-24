
#--------------------------------------------------------------------------------
#
# Nigel Hamilton (2016-Now) - Artistic Licence 2.0
#
# jmp - jump quickly to edit matching files
#
#--------------------------------------------------------------------------------

unit class JMP;

use JMP::Config;
use JMP::Editor;
use JMP::Finder;
use JMP::UI;

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

method find-files-in-command-output ($title, $command) {

    my @hits = self.finder.find-files-in-command-output($command);    
    self.display-hits($title, @hits);

}

method search-in-files ($title, $search-terms) {

    # finish if nothing found?    
    my @hits = self.finder.find-in-files($search-terms);
    self.display-hits($title, @hits);

}

submethod BUILD {
    $!config = JMP::Config.new;
    $!editor = JMP::Editor.new(:$!config);
    $!finder = JMP::Finder.new(:$!config);
}

submethod display-hits ($title, @hits) {

    return unless @hits.elems;

    # display the results
    JMP::UI.new(
        :$title, 
        :@hits,
        :$!editor,
    ).display;

}
