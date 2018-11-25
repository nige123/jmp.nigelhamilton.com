
class JMP::UI::Cursor {

    has $.at-line;          
    has $.bottom-line;
    has $.top-line;          

    method at-bottom {
        return $!at-line == $!bottom-line;
    }

    method at-top {
        return $!at-line == $!top-line;
    }

    method display-at-line ($screen, $cursor-at-line) {

        # change the cursor position
        self.render-at-line($screen, $cursor-at-line);

        # display
        print $screen;
    }

    method render-at-line ($screen, $cursor-at-line) {

        # change the cursor grid position - don't display yet
        $screen.current-grid.set-span-color(0, $screen.columns, $!at-line, 'default');

        $!at-line = $cursor-at-line;

        $screen.current-grid.set-span-color(0, $screen.columns, $!at-line, 'inverse');
    }

    method move-down ($screen) {
        return if $.at-line == $.bottom-line;
        return self.display-at-line($screen, $.at-line + 1);
    }

    method move-up ($screen) {
        return if $.at-line == $.top-line;
        return self.display-at-line($screen, $.at-line - 1);
    }

}

