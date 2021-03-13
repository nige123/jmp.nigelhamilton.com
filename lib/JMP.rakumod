
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
use JMP::Memory;
use JMP::UI;

has JMP::Config $.config;
has JMP::Editor $.editor;
has JMP::Finder $.finder;
has JMP::Memory $.memory;

has $.command;

method edit-config {
    $!editor.edit-file($!config.config-file);
}

method edit-file ($filename, $line-number = 1) {
    my $hit = self.finder.find-line-in-file($filename, $line-number);
    return $!editor.edit($.command, $hit);
}

method edit-file-at-matching-line ($filename, $search-terms) {
    my $hit = self.finder.find-matching-line-in-file($filename, $search-terms);
    return $!editor.edit($.command, $hit);
}

method find-files-in-command-output ($sub-command) {
    my @hits = self.finder.find-files-in-command-output($sub-command);
    self.display-hits(@hits);
}

method search-in-files ($search-terms) {
    my @hits = self.finder.find-in-files($search-terms);
    self.display-hits(@hits);
}

method recent-jmps ($last-n-entries) {
    my @hits = self.memory.get-recent-jmps($last-n-entries);
    self.display-hits(@hits);
}

submethod TWEAK {
    $!config = JMP::Config.new;
    $!memory = JMP::Memory.new;
    $!editor = JMP::Editor.new(:$!config, :$!memory);
    $!finder = JMP::Finder.new(:$!config);
}

submethod display-hits (@hits) {

    return unless @hits.elems;

    # display the results
    JMP::UI.new(
        title => self.command,
        :@hits,
        :$!editor,
    ).display;

}
