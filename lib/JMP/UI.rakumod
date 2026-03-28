
use Terminal::UI;
use JMP::File::Hit;

class JMP::UI {

    has $.title     is required;
    has $.editor    is required;
    has @.hits      is required;

    has $.ui;
    has $!preview-hit;
    has Int $!preview-line-number = 1;

    method !detect-screen-rows {
        my $rows = (%*ENV<LINES> // '').Int;
        if $rows < 2 {
            my $tput = qx{tput lines 2>/dev/null}.trim;
            $rows = $tput.Int if $tput ~~ /^\d+$/;
        }
        return 24 if $rows < 2;
        return $rows;
    }

    method pane-heights-for-rows (Int $rows) {
        my $top-lines = 15;
        my $footer-lines = 1;

        # keep a preview pane available even on very small terminals
        if $rows <= 14 {
            $top-lines = $rows - 2;
            $top-lines = 1 if $top-lines < 1;
        }

        my $preview-lines = $rows - $top-lines - $footer-lines;
        $preview-lines = 1 if $preview-lines < 1;

        return [$top-lines, $preview-lines, $footer-lines];
    }

    method clamp-preview-line (Int $requested-line, Int $max-line) {
        return 1 if $max-line < 1;
        return 1 if $requested-line < 1;
        return $max-line if $requested-line > $max-line;
        return $requested-line;
    }

    method !resolve-editable-hit (Int $hit-index) {
        my $hit = @!hits[$hit-index] // return;

        # command history entries are not editable files
        return if $hit.isa('JMP::Memory::Command');

        if $hit.isa('JMP::File::HitLater') {
            $hit.find-file-path;
        }

        return unless $hit.file-exists;
        return $hit;
    }

    method !preview-selected-hit (Terminal::UI $ui, Terminal::UI::Pane $preview, Int $hit-index) {
        my $hit = self!resolve-editable-hit($hit-index);

        $preview.clear;

        unless $hit {
            $preview.put('No preview available for this entry.');
            $preview.select-first;
            $ui.focus(pane => 1);
            return;
        }

        $!preview-hit = $hit;

        my $file = $hit.absolute-path;
        my @lines = $file.IO.lines(:enc('utf8-c8'));

        if @lines.elems == 0 {
            $preview.put('     1:');
            $preview.select-first;
            $!preview-line-number = 1;
            $ui.focus(pane => 1);
            return;
        }

        for @lines.kv -> $index, $line {
            my $line-number = $index + 1;
            my %meta = line-number => $line-number;
            $preview.put($line-number.fmt('%6d') ~ ': ' ~ $line, :%meta);
        }

        my $target-line = self.clamp-preview-line($hit.line-number.Int, @lines.elems.Int);
        $preview.select($target-line - 1);
        $!preview-line-number = $target-line;

        $ui.focus(pane => 1);
    }

    method !edit-preview-selection (Terminal::UI $ui) {
        return unless $!preview-hit;

        my $line-number = $!preview-line-number // $!preview-hit.line-number // 1;

        my $hit = JMP::File::Hit.new(
            relative-path => $!preview-hit.relative-path,
            absolute-path => $!preview-hit.absolute-path,
            :$line-number,
        );

        $ui.pause-and-do({
            $!editor.edit($!title, $hit);
        });
        $ui.refresh(:hard);
    }

    method display {

        my $ui = Terminal::UI.new;
        $!ui = $ui;

        # Terminal::UI heights are content rows, excluding frame borders/divider.
        # For 3 panes: available = total rows - 4 (top + 2 dividers + bottom border).
        my $screen-rows = self!detect-screen-rows;
        my $available-rows = $screen-rows - 4;
        $available-rows = 3 if $available-rows < 3;
        my @pane-heights = self.pane-heights-for-rows($available-rows.Int);
        $ui.setup(heights => @pane-heights);

        my $results = $ui.panes[0];
        my $preview = $ui.panes[1];
        my $footer = $ui.panes[2];

        # Display help text in preview pane
        $preview.put('Press Enter on a result to preview the file here.');
        $preview.put('Press Enter again in this pane to open the editor.');

        # Display key hints in footer pane
        $footer.put('[h]← [l]→ page  [q]uit  [Enter] select');

        # Display search results in results pane
        for @!hits.kv -> $index, $hit {
            my %meta = hit-index => $index;
            $results.put($hit.render, :%meta);
        }

        $results.select-first;
        $ui.focus(pane => 0);

        $results.on: select => -> :%meta {
            self!preview-selected-hit($ui, $preview, +(%meta<hit-index> // 0));
        };

        $preview.on: select => -> :%meta {
            $!preview-line-number = +(%meta<line-number> // 1);
            self!edit-preview-selection($ui);
        };

        # keep JMP keybindings for paging and exit
        $ui.bind('pane', CursorRight => 'page-down', l => 'page-down');
        $ui.bind('pane', CursorLeft => 'page-up', h => 'page-up');
        $ui.bind(q => 'quit', Q => 'quit');

        LEAVE $ui.shutdown;
        $ui.interact;
    }
}
