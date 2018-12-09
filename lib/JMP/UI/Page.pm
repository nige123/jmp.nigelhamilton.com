
use JMP::UI::Cursor;

class JMP::UI::Page {

    our $header-height = 2;
    our $footer-height = 2;

    our sub calculate-body-lines-per-page ($total-lines) is export {
        return $total-lines - ($header-height + $footer-height);
    }
    
    has @.hits;
    has $.page-number;
    has $.title;
    has $.total-pages;

    has $.cursor;          

    submethod TWEAK {
        $!cursor = JMP::UI::Cursor.new(
                        at-line     => $header-height,
                        top-line    => $header-height,
                        bottom-line => ($header-height + @!hits.elems) - 1,
                    );
    }

    method display ($screen, $cursor-at-line = self.cursor.top-line) {
        $screen.current-grid.clear;    
        self.render-header($screen);
        self.render-hits($screen);
        self.render-footer($screen);
        self.cursor.render-at-line($screen, $cursor-at-line);
        print $screen;
    }
        
    submethod get-footer-actions { 
        return '                [E]dit      e[X]it            ' if $!page-number == 1 and $!total-pages == 1;
        return '                [E]dit      e[X]it      Next 🠊' if $!page-number == 1;
        return '🠈 Previous      [E]dit      e[X]it            ' if $!page-number == $!total-pages;
        return '🠈 Previous      [E]dit      e[X]it      Next 🠊';
    }

    method is-first-page {
        return $!page-number == 1;
    }

    method is-last-page {
        return $!page-number == $!total-pages;
    }

    submethod render-footer ($screen) {            
        self.render-line($screen, $screen.rows - 2);
        my $actions      = self.get-footer-actions;
        my $left-padding = ' ' x ($screen.columns - $actions.chars) div 2;
        $screen.current-grid.set-span-text(0, $screen.rows - 1, $left-padding ~ $actions);
    }

    submethod render-header ($screen) {            
        # render the header
        $screen.current-grid.set-span-text(0, 0, $!title);
        my $page-caption = 'Page ' ~ $!page-number ~ ' of ' ~ $!total-pages;
        $screen.current-grid.set-span-text($screen.columns - $page-caption.chars, 0, $page-caption);
        self.render-line($screen, 1);
    }

    submethod render-hits ($screen) {        
        # start at the top cursor line position
        my $current-line = $!cursor.top-line;

        for @!hits -> $hit {
            $screen.current-grid.set-span-text(0, $current-line, $hit.render);
            $screen.current-grid.set-span-color(0, $screen.columns, $current-line, 'default');
            $current-line++;
        }
    }

    submethod render-line ($screen, $at-line) {
        $screen.current-grid.set-span-text(0, $at-line, '─' x $screen.columns);        
    }

    method get-selected-hit {
        return @!hits[self.cursor.at-line - self.cursor.top-line];
    }

}
