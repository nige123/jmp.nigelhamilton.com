
use Terminal::UI;
use JMP::File::Hit;

class JMP::UI {

    has $.title     is required;
    has $.editor    is required;
    has @.hits      is required;

    has $.ui;
    has $!preview-hit;
    has Int $!preview-line-number = 1;

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
        my $quit-token = 'JMP_UI_IMMEDIATE_QUIT';

        # Fixed 1-row title and footer; results fixed at 15 rows; preview takes remaining space.
        $ui.setup(heights => [1, 15, fr => 1, 1]);

        my ($title, $results, $preview, $footer) = $ui.panes;

        # Title and footer are display-only: prevent focus and disable scrolling.
        $title.selectable  = False;
        $title.auto-scroll = False;
        $footer.selectable  = False;
        $footer.auto-scroll = False;

        # Display command title in the fixed title pane
        $title.put($!title);

        # Display help text in preview pane
        $preview.put('Press Enter on a result to preview the file here.');
        $preview.put('Press Enter again in this pane to open the editor.');

        # Display key hints in footer pane
        $footer.put('[h]← [l]→ page  [q/x] quit  [Enter] select');

        # Display search results in results pane
        for @!hits.kv -> $index, $hit {
            my %meta = hit-index => $index;
            $results.put($hit.render, :%meta);
        }

        $results.select-first;
        $ui.focus(pane => 1);

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
        # Keep one real 'quit' action mapped so Terminal::UI interact() can resolve done key.
        # q/x use a synchronous immediate quit path.
        $ui.bind(Q => 'quit', q => 'jmp-quit', x => 'jmp-quit', X => 'jmp-quit');
        $ui.on-sync(|{
            'jmp-quit' => -> {
                $ui.shutdown;
                die $quit-token;
            }
        });

        LEAVE {
            $ui.shutdown;
            # Restore terminal line discipline (raw→cooked) and print a
            # trailing newline so the shell prompt appears on a fresh line.
            run 'stty', 'sane';
            print "\n";
            $*OUT.flush;
        }
        try {
            $ui.interact;
            CATCH {
                default {
                    if .message ne $quit-token {
                        .rethrow;
                    }
                }
            }
        }
    }
}
