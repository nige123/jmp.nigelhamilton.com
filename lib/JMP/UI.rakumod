
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
    has $.locater;
    has $!preview-hit;
    has Int $!preview-line-number = 1;
    has Bool $!editing-preview = False;
    has $!results-pane;
    has $!preview-pane;
    has $!title-pane;
    has $!footer-pane;
    has Str $!footer-text = '';
    has Str $!search-buffer = '';
    has Str $!output-buffer = '';
    has Str $!locate-buffer = '';
    has Str $!input-context = '';
    has Bool $!shutdown-done = False;

    #| the footer's version label
    method version-text { 'jmp v' ~ JMP::Version::VERSION }

    #| the footer's action hints, one per available callback
    method footer-actions-text {
        my $text = '[↑][↓] [←][→] select';
        $text ~= '  [i]n search' if $!searcher.defined;
        $text ~= '  [o]n cmd'    if $!outputer.defined;
        $text ~= '  [t]o file'   if $!locater.defined;
        $text ~= '  [h]elp  [q]uit';
        return $text;
    }

    #| results pane rows and preview pane rows for a terminal of $total-height rows:
    #| results take 35% of the terminal, and each pane keeps at least one row
    method pane-heights (Int $total-height) {
        # the frame spends rows on borders, dividers, the title and the footer
        my $content-rows = $total-height - 8;
        return (1, 1) if $content-rows < 2;

        my $results-height = ($total-height * 35) div 100;
        $results-height = 1 if $results-height < 1;
        $results-height = $content-rows - 1 if $results-height > $content-rows - 1;

        my $preview-height = $content-rows - $results-height;
        $preview-height = 1 if $preview-height < 1;

        return ($results-height, $preview-height);
    }

    #| which pane the cursor counter follows
    method !focus-name {
        return 'results' unless $!ui.defined && $!preview-pane.defined;
        my $focused = try $!ui.focused;
        return $focused.defined && $focused === $!preview-pane ?? 'preview' !! 'results';
    }

    method !results-index { $!results-pane.defined ?? ($!results-pane.current-line-index // 0) !! 0 }
    method !preview-index { $!preview-pane.defined ?? ($!preview-pane.current-line-index // 0) !! 0 }
    method !preview-count { $!preview-pane.defined ?? $!preview-pane.lines.elems !! 0 }

    #| the footer's cursor counter: `current/total` for the focused pane, 1-based,
    #| relative to the loaded preview window rather than the file
    method cursor-position-text (
        Str :$focus          = self!focus-name,
        Int :$selected-index = self!results-index,
        Int :$preview-index  = self!preview-index,
        Int :$preview-count  = self!preview-count,
    ) {
        my ($current, $total);

        if $focus eq 'preview' {
            $total   = $preview-count;
            $current = $preview-index + 1;
        }
        else {
            $total   = @!hits.elems;
            $current = $selected-index + 1;
        }

        return '0/0' if $total < 1;
        $current = 1      if $current < 1;
        $current = $total if $current > $total;
        return "$current/$total";
    }

    method !fit-to-width (Str $text, Int $width) {
        return $text.substr(0, $width) if $text.chars > $width;
        return $text ~ (' ' x ($width - $text.chars));
    }

    #| lay out the footer in three zones: the counter at the left, the actions
    #| centred in the middle, the version at the right. The actions go first
    #| when space runs short; then only the version remains.
    method render-footer-line (Str $left, Str $actions, Str $version, Int $width) {
        my $left-width    = $left.chars;
        my $version-width = $version.chars;

        # not even room for counter, a space and the version: version only
        if $left-width + 1 + $version-width > $width {
            return self!fit-to-width($version, $width);
        }

        my $middle-width = $width - $left-width - $version-width - 2;

        # no room for actions: the slack sits between counter and version
        if $middle-width <= 0 {
            my $gap = $width - $left-width - $version-width;
            return $left ~ (' ' x $gap) ~ $version;
        }

        my $clipped = $actions.chars > $middle-width ?? $actions.substr(0, $middle-width) !! $actions;
        my $total-padding = $middle-width - $clipped.chars;
        my $padding-left  = $total-padding div 2;
        my $padding-right = $total-padding - $padding-left;

        return $left ~ ' ' ~ (' ' x $padding-left) ~ $clipped ~ (' ' x $padding-right) ~ ' ' ~ $version;
    }

    method !render-footer {
        return unless $!footer-pane;

        my $line = self.render-footer-line(
            self.cursor-position-text,
            $!footer-text,
            self.version-text,
            $!footer-pane.width.Int,
        );

        $!footer-pane.update($line, line => 0);
    }

    method !green-cursor {
        return "\e[32m▌\e[0m";
    }

    method !render-title-line (Str $text) {
        return unless $!title-pane;

        $!title-pane.update($text, line => 0);
    }

    #| the buffer being typed into for the current input context
    method !current-buffer {
        return $!output-buffer if $!input-context eq 'output';
        return $!locate-buffer if $!input-context eq 'locate';
        return $!search-buffer;
    }

    method !set-current-buffer (Str $value) {
        if    $!input-context eq 'output' { $!output-buffer = $value }
        elsif $!input-context eq 'locate' { $!locate-buffer = $value }
        else                              { $!search-buffer = $value }
    }

    method !clear-buffers {
        $!search-buffer = '';
        $!output-buffer = '';
        $!locate-buffer = '';
    }

    #| the title line while typing: `jmp in|on|to <text>` with a cursor
    method !render-prompt {
        return unless $!title-pane;

        my $verb = $!input-context eq 'output' ?? 'on'
                !! $!input-context eq 'locate' ?? 'to'
                !!                                'in';
        self!render-title-line("jmp $verb " ~ self!current-buffer ~ self!green-cursor);
    }

    method !restore-chrome (Terminal::UI $ui) {
        return unless $!title-pane && $!footer-pane;

        if $!input-context {
            self!render-prompt;
        }
        else {
            self!render-title-line($!title);
        }

        self!render-footer;
        $!title-pane.redraw;
        $!footer-pane.redraw;
        $ui.refresh;
    }

    #| move focus to a pane and keep the footer's counter in step
    method !focus-pane (Terminal::UI $ui, Int $pane) {
        $ui.focus(:$pane);
        self!render-footer;
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
            't              Locate a file on the filesystem (jmp to ...)',
            'q / x          Quit jmp',
            'h / ?          Show this help',
        );

        unless $!searcher.defined {
            @lines = @lines.grep(* !~~ /^ 'i' \s/);
        }

        unless $!outputer.defined {
            @lines = @lines.grep(* !~~ /^ 'o' \s/);
        }

        unless $!locater.defined {
            @lines = @lines.grep(* !~~ /^ 't' \s/);
        }

        for @lines -> $line {
            $preview.put($line, wrap => 'word');
        }

        $preview.select-first;
        $ui.focus(pane => 2);
        self!restore-chrome($ui);
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

    method load-locate-results (Str $filename, $results) {
        return False unless $!locater.defined;

        my $trimmed = $filename.trim;
        return False unless $trimmed;

        $!title = 'jmp to ' ~ $trimmed;
        my @new-hits = $!locater.($trimmed);
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
            self!focus-pane($ui, 2);
            return;
        }

        $!preview-hit = $hit;

        my $file = $hit.absolute-path;
        # Slurp eagerly so the file handle is released before preview rendering.
        my @lines = $file.IO.slurp(:enc('utf8-c8')).lines;

        if @lines.elems == 0 {
            # an empty file previews as one empty line
            $preview.put('', meta => { line-number => 1 });
            $preview.select-first;
            $!preview-line-number = 1;
            self!focus-pane($ui, 2);
            return;
        }

        my ($start, $end) = self.preview-window(@lines.elems.Int, $hit.line-number.Int);

        # the preview shows the lines themselves, without line numbers.
        # :!scroll-ok appends each line without scrolling the pane, so loading
        # a window costs one redraw at select time instead of one terminal
        # scroll per line (which showed as the preview crawling to its line).
        for ($start - 1) .. ($end - 1) -> $index {
            my %meta = line-number => $index + 1;
            $preview.put(@lines[$index], :%meta, :!scroll-ok);
        }

        my $target-line = self.clamp-preview-line($hit.line-number.Int, @lines.elems.Int);
        $preview.select($target-line - $start);
        $!preview-line-number = $target-line;

        self!focus-pane($ui, 2);
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
        $ui.focus(pane => 2);
        self!restore-chrome($ui);
        $!editing-preview = False;
    }

    #| pane heights for Terminal::UI: title, results, preview, footer.
    #| $available is the frame's content rows; the frame itself spends six more
    #| (two borders, four divider rows) so the terminal has $available + 6 rows.
    method !frame-heights (Int $available) {
        my $rows = $available + 6;
        my ($results-height, $preview-height) = self.pane-heights($rows);
        my $chrome = 2;                                  # title and footer
        $results-height = 1 if $results-height < 1;
        $results-height = $available - $chrome - 1 if $results-height > $available - $chrome - 1;
        $results-height = 1 if $results-height < 1;
        $preview-height = $available - $chrome - $results-height;
        $preview-height = 1 if $preview-height < 1;
        return [1, $results-height, $preview-height, 1];
    }

    method display {

        my $ui = Terminal::UI.new;
        $!ui = $ui;
        $!shutdown-done = False;
        my $quit-token = 'JMP_UI_IMMEDIATE_QUIT';

        # 1-row title and footer; results take 35% of the terminal; preview takes the rest.
        # Built by hand rather than with setup(heights => &callback): Rakudo 2026.07
        # reads Terminal::UI's `Callable :&heights!` candidate as Callable[Callable],
        # so no callback ever dispatches to it and the UI died before drawing.
        # `fr => 1` gives the preview pane a height computer, so it still follows a resize.
        my $frame = $ui.add-screen.add-frame;
        $frame.number-of-dividers = 3;                   # four panes
        my ($title-height, $results-height, $, $footer-height) = self!frame-heights($frame.available-rows.Int);
        $frame.add-panes(heights => [$title-height, $results-height, fr => 1, $footer-height]);
        $ui.refresh;

        my ($title, $results, $preview, $footer) = $ui.panes;
        $!results-pane = $results;
        $!preview-pane = $preview;

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
        $preview.put('Press [t] to locate a file on the filesystem.');

        # Display key hints in footer pane.
        $!footer-text = self.footer-actions-text;
        $!title-pane  = $title;
        $!footer-pane = $footer;

        # Display search results in results pane
        for @!hits.kv -> $index, $hit {
            my %meta = hit-index => $index;
            $results.put($hit.render, :%meta);
        }

        $results.select-first;
        $ui.focus(pane => 1);
        self!restore-chrome($ui);

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
        $results.on-sync(name => 'jmp-left', action => -> { $results.page-up; self!render-footer; });
        $preview.on-sync(name => 'jmp-left', action => -> { self!focus-pane($ui, 1); });

        # Moving the selection runs Terminal::UI's own action, then updates the counter.
        for $results, $preview -> $pane {
            for <select-up select-down select-up_10 select-down_10 page-up page-down select-first select-last> -> $name {
                $pane.on-sync(name => $name, action => -> { $pane."$name"(); self!render-footer; });
            }
        }

        # [i]n, [o]n and [t]o: accumulate typed chars in input mode, run on Enter
        $results.on-sync: input => -> $arg {
            given $arg {
                when 'Enter' {
                    $ui.mode = 'command';
                    my $updated = False;

                    if $!input-context eq 'search' {
                        $updated = self.load-search-results($!search-buffer, $results);
                    }
                    elsif $!input-context eq 'output' {
                        $updated = self.load-command-output($!output-buffer, $results);
                    }
                    elsif $!input-context eq 'locate' {
                        $updated = self.load-locate-results($!locate-buffer, $results);
                    }

                    self!clear-buffers;
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
                    self!clear-buffers;
                    $!input-context = '';
                    self!render-title-line($!title);
                }
                when 'Delete' | "\x08" {
                    my $buffer = self!current-buffer;
                    self!set-current-buffer($buffer.chars > 0 ?? $buffer.substr(0, $buffer.chars - 1) !! '');
                    self!render-prompt;
                }
                default {
                    if $arg.chars == 1 {
                        self!set-current-buffer(self!current-buffer ~ $arg);
                        self!render-prompt;
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
                    self!focus-pane($ui, 1);
                    return;
                }

                self!shutdown-cleanly($ui);
                die $quit-token;
            }
        });

        # entering input mode for a context: focus the results and show the prompt
        my &start-input = -> Str $context {
            $ui.focus(pane => 1);
            self!clear-buffers;
            $!input-context = $context;
            self!render-prompt;
            $ui.mode = 'input';
        };

        if $!searcher.defined {
            $ui.bind(i => 'new-search');
            $ui.on-sync(|{ 'new-search' => -> { start-input('search') } });
        }

        if $!outputer.defined {
            $ui.bind(o => 'new-output');
            $ui.on-sync(|{ 'new-output' => -> { start-input('output') } });
        }

        if $!locater.defined {
            $ui.bind(t => 'new-locate');
            $ui.on-sync(|{ 'new-locate' => -> { start-input('locate') } });
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
