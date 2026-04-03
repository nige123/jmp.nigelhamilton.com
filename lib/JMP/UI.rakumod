
use Terminal::UI;
use JMP::File::Hit;
use JMP::Version;

class JMP::UI {

    has $.title     is required;
    has $.editor    is required;
    has @.hits      is required;

    has $.ui;
    has $.searcher;
    has $.outputer;
    has $!preview-hit;
    has Int $!preview-line-number = 1;
    has Bool $!editing-preview = False;
    has $!title-pane;
    has $!footer-pane;
    has Str $!footer-text;
    has Str $!search-buffer = '';
    has Str $!output-buffer = '';
    has Str $!input-context = '';
    has Bool $!shutdown-done = False;

    method !center-text (Str $text, Int $width) {
        return $text if $width <= $text.chars;

        my $padding = ($width - $text.chars) div 2;
        return (' ' x $padding) ~ $text;
    }

    method !render-footer {
        return unless $!footer-pane;

        my $version = 'jmp v' ~ JMP::Version::VERSION;
        my $width = $!footer-pane.width.Int;
        my $actions-width = $width - $version.chars - 1;

        my $line;
        if $actions-width > 0 {
            my $actions = self!center-text($!footer-text, $actions-width);
            if $actions.chars < $actions-width {
                $actions ~= ' ' x ($actions-width - $actions.chars);
            }
            $line = $actions ~ ' ' ~ $version;
        } else {
            $line = $version;
        }

        if $line.chars < $width {
            $line ~= ' ' x ($width - $line.chars);
        }
        elsif $line.chars > $width {
            $line = $line.substr(0, $width);
        }

        $!footer-pane.update($line, line => 0);
    }

    method !green-cursor {
        return "\e[32m▌\e[0m";
    }

    method !render-title-line (Str $text) {
        return unless $!title-pane;

        $!title-pane.update($text, line => 0);
    }

    method !render-search-prompt {
        return unless $!title-pane;

        self!render-title-line('jmp in ' ~ $!search-buffer ~ self!green-cursor);
    }

    method !render-output-prompt {
        return unless $!title-pane;

        self!render-title-line('jmp on ' ~ $!output-buffer ~ self!green-cursor);
    }

    method !restore-chrome (Terminal::UI $ui) {
        return unless $!title-pane && $!footer-pane;

        if $!input-context eq 'search' {
            self!render-search-prompt;
        }
        elsif $!input-context eq 'output' {
            self!render-output-prompt;
        }
        else {
            self!render-title-line($!title);
        }

        self!render-footer;
        $!title-pane.redraw;
        $!footer-pane.redraw;
        $ui.refresh;
    }

    method !show-help-in-preview (Terminal::UI $ui, Terminal::UI::Pane $preview) {
        $!preview-hit = Nil;
        $preview.clear;

        my @lines = (
            'jmp help',
            '',
            'Use arrow keys to move between results and preview, then open what is selected.',
            '',
            'Right / Enter  Open selected result or preview line',
            'Left           Return focus from preview to results',
            'Up / Down      Move selection',
            'PageUp / l     Page through content',
            'i              Search in files (jmp in ...)',
            'o              Jump on files in command output (jmp on ...)',
            'q / x          Quit jmp',
            'h / ?          Show this help',
        );

        unless $!searcher.defined {
            @lines = @lines.grep(* !~~ /^ 'i' \s/);
        }

        unless $!outputer.defined {
            @lines = @lines.grep(* !~~ /^ 'o' \s/);
        }

        for @lines -> $line {
            $preview.put($line, wrap => 'word');
        }

        $preview.select-first;
        self!restore-chrome($ui);
        $ui.focus(pane => 2);
    }

    method !load-results-into-pane ($results, @new-hits) {
        @!hits = @new-hits;
        $results.clear;

        if @!hits.elems {
            for @!hits.kv -> $index, $hit {
                my %meta = hit-index => $index;
                $results.put($hit.render, :%meta);
            }
            $results.select-first;
            return;
        }

        $results.put('(no output lines)');
        $results.select-first;
    }

    method load-search-results (Str $terms, $results) {
        return False unless $!searcher.defined;

        my $trimmed = $terms.trim;
        return False unless $trimmed;

        $!title = 'jmp in ' ~ $trimmed;
        my @new-hits = $!searcher.($trimmed);
        self!load-results-into-pane($results, @new-hits);
        return True;
    }

    method load-command-output (Str $command, $results) {
        return False unless $!outputer.defined;

        my $trimmed = $command.trim;
        return False unless $trimmed;

        $!title = 'jmp on ' ~ $trimmed;
        my @new-hits = $!outputer.($trimmed);
        self!load-results-into-pane($results, @new-hits);
        return True;
    }

    method !shutdown-cleanly (Terminal::UI $ui) {
        return if $!shutdown-done;

        $!shutdown-done = True;
        $ui.shutdown;
        # Leave terminal in a clean prompt state: column 1, cleared line.
        print "\r\e[2K";
        $*OUT.flush;
    }

    method !resume-after-editor {
        print "Press any key to resume jmp: ";
        $*IN.read(1);
        print "\n";
    }

    method clamp-preview-line (Int $requested-line, Int $max-line) {
        return 1 if $max-line < 1;
        return 1 if $requested-line < 1;
        return $max-line if $requested-line > $max-line;
        return $requested-line;
    }

    method preview-window (Int $max-line, Int $target-line, Int $window-size = 400) {
        return (1, 1) if $max-line < 1;

        my $safe-target = self.clamp-preview-line($target-line, $max-line);
        my $window = $window-size < 1 ?? 1 !! $window-size;

        return (1, $max-line) if $max-line <= $window;

        my $half = $window div 2;
        my $start = $safe-target - $half;
        my $end = $start + $window - 1;

        if $start < 1 {
            $start = 1;
            $end = $window;
        }

        if $end > $max-line {
            $end = $max-line;
            $start = $end - $window + 1;
        }

        return ($start, $end);
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
            $ui.focus(pane => 2);
            return;
        }

        $!preview-hit = $hit;

        my $file = $hit.absolute-path;
        # Slurp eagerly so the file handle is released before preview rendering.
        my @lines = $file.IO.slurp(:enc('utf8-c8')).lines;

        if @lines.elems == 0 {
            $preview.put('     1:');
            $preview.select-first;
            $!preview-line-number = 1;
            $ui.focus(pane => 2);
            return;
        }

        my ($start, $end) = self.preview-window(@lines.elems.Int, $hit.line-number.Int);

        for ($start - 1) .. ($end - 1) -> $index {
            my $line = @lines[$index];
            my $line-number = $index + 1;
            my %meta = line-number => $line-number;
            $preview.put($line-number.fmt('%6d') ~ ': ' ~ $line, :%meta);
        }

        my $target-line = self.clamp-preview-line($hit.line-number.Int, @lines.elems.Int);
        $preview.select($target-line - $start);
        $!preview-line-number = $target-line;

        $ui.focus(pane => 2);
    }

    method !edit-preview-selection (Terminal::UI $ui) {
        return if $!editing-preview;
        return unless $!preview-hit;

        my $line-number = $!preview-line-number // $!preview-hit.line-number // 1;

        my $hit = JMP::File::Hit.new(
            relative-path => $!preview-hit.relative-path,
            absolute-path => $!preview-hit.absolute-path,
            :$line-number,
        );

        $!editing-preview = True;
        $!editor.edit($!title, $hit);
        $ui.refresh(:hard);
        self!restore-chrome($ui);
        $ui.focus(pane => 2);
        $!editing-preview = False;
    }

    method display {

        my $ui = Terminal::UI.new;
        $!ui = $ui;
        $!shutdown-done = False;
        my $quit-token = 'JMP_UI_IMMEDIATE_QUIT';

        # Fixed 1-row title and footer; results fixed at 15 rows; preview takes remaining space.
        $ui.setup(heights => [1, 15, fr => 1, 1]);

        my ($title, $results, $preview, $footer) = $ui.panes;

        # Title and footer are display-only: prevent focus and disable scrolling.
        $title.selectable  = False;
        $title.auto-scroll = False;
        $footer.selectable  = False;
        $footer.auto-scroll = False;

        # Display help text in preview pane
        $preview.put('Press Right Arrow on a result to preview the file here.');
        $preview.put('Press Right Arrow again in this pane to open the editor.');
        $preview.put('Press [i] to search in files for keywords.');
        $preview.put('Press [o] to run a command and jump on its output.');

        # Display key hints in footer pane.
        my $in-hint = $!searcher.defined ?? '  [i]n search' !! '';
        my $on-hint = $!outputer.defined ?? '  [o]n cmd'    !! '';
        $!footer-text = '[↑][↓] [←][→] select ' ~ $in-hint ~ $on-hint ~ '  [h]elp  [q]uit';
        $!title-pane  = $title;
        $!footer-pane = $footer;
        self!restore-chrome($ui);

        # Display search results in results pane
        for @!hits.kv -> $index, $hit {
            my %meta = hit-index => $index;
            $results.put($hit.render, :%meta);
        }

        $results.select-first;
        $ui.focus(pane => 1);

        my &select-results = -> :%meta {
            self!preview-selected-hit($ui, $preview, +(%meta<hit-index> // 0));
        };
        $results.on-sync: select => &select-results;
        $results.on-sync(name => 'jmp-select', action => &select-results);

        my &select-preview = -> :%meta {
            $!preview-line-number = +(%meta<line-number> // 1);
            self!edit-preview-selection($ui);
        };
        $preview.on-sync: select => &select-preview;
        $preview.on-sync(name => 'jmp-select', action => &select-preview);
        my &show-help = -> {
            self!show-help-in-preview($ui, $preview);
        };
        $results.on-sync(name => 'jmp-help', action => &show-help);
        $preview.on-sync(name => 'jmp-help', action => &show-help);
        $results.on-sync(name => 'jmp-left', action => -> { $results.page-up; });
        $preview.on-sync(name => 'jmp-left', action => -> { $ui.focus(pane => 1); });

        # [t]o interactive search: accumulate typed chars in input mode, run search on Enter
        $results.on-sync: input => -> $arg {
            given $arg {
                when 'Enter' {
                    $ui.mode = 'command';
                    my $updated = False;

                    if $!input-context eq 'search' {
                        $updated = self.load-search-results($!search-buffer, $results);
                        $!search-buffer = '';
                    }
                    elsif $!input-context eq 'output' {
                        $updated = self.load-command-output($!output-buffer, $results);
                        $!output-buffer = '';
                    }

                    $!input-context = '';

                    if $updated {
                        $ui.refresh(:hard);
                        self!restore-chrome($ui);
                    }
                    else {
                        self!render-title-line($!title);
                    }
                }
                when 'Esc' {
                    $ui.mode = 'command';
                    $!search-buffer = '';
                    $!output-buffer = '';
                    $!input-context = '';
                    self!render-title-line($!title);
                }
                when 'Delete' | "\x08" {
                    if $!input-context eq 'output' {
                        my $new-length = $!output-buffer.chars > 0 ?? $!output-buffer.chars - 1 !! 0;
                        $!output-buffer = $!output-buffer.substr(0, $new-length);
                        self!render-output-prompt;
                    }
                    else {
                        my $new-length = $!search-buffer.chars > 0 ?? $!search-buffer.chars - 1 !! 0;
                        $!search-buffer = $!search-buffer.substr(0, $new-length);
                        self!render-search-prompt;
                    }
                }
                default {
                    if $arg.chars == 1 {
                        if $!input-context eq 'output' {
                            $!output-buffer ~= $arg;
                            self!render-output-prompt;
                        }
                        else {
                            $!search-buffer ~= $arg;
                            self!render-search-prompt;
                        }
                    }
                }
            }
        };

        # Keep explicit JMP keybindings.
        # Right arrow and Enter select; left arrow goes back from preview; l pages down.
        # Terminal::UI key names are Right/Left; keep CursorRight/CursorLeft for compatibility.
        $ui.bind('pane', Right => 'jmp-select', CursorRight => 'jmp-select', l => 'page-down', h => 'jmp-help');
        $ui.bind('pane', Left => 'jmp-left', CursorLeft => 'jmp-left', PageUp => 'page-up', Enter => 'select');
        # Keep one real 'quit' action mapped so Terminal::UI interact() can resolve done key.
        # q/x use a synchronous immediate quit path.
        # Esc is context-sensitive: preview pane -> results pane, results pane -> quit.
        $ui.bind('?' => 'jmp-help', Q => 'quit', q => 'jmp-quit', x => 'jmp-quit', X => 'jmp-quit', Esc => 'jmp-escape');
        $ui.on-sync(|{
            'jmp-help' => -> {
                self!show-help-in-preview($ui, $preview);
            },
            'jmp-quit' => -> {
                self!shutdown-cleanly($ui);
                die $quit-token;
            },
            'jmp-escape' => -> {
                if $ui.focused === $preview {
                    $ui.focus(pane => 1);
                    return;
                }

                self!shutdown-cleanly($ui);
                die $quit-token;
            }
        });

        if $!searcher.defined {
            $ui.bind(i => 'new-search');
            $ui.on-sync(|{
                'new-search' => -> {
                    $ui.focus(pane => 1);
                    $!search-buffer = '';
                    $!input-context = 'search';
                    self!render-search-prompt;
                    $ui.mode = 'input';
                }
            });
        }

        if $!outputer.defined {
            $ui.bind(o => 'new-output');
            $ui.on-sync(|{
                'new-output' => -> {
                    $ui.focus(pane => 1);
                    $!output-buffer = '';
                    $!input-context = 'output';
                    self!render-output-prompt;
                    $ui.mode = 'input';
                }
            });
        }

        try {
            $ui.interact;
            CATCH {
                default {
                    if .message ne $quit-token {
                        self!shutdown-cleanly($ui);
                        .rethrow;
                    }
                }
            }
        }

        self!shutdown-cleanly($ui);
    }
}
