
use JMP::UI::Page;

class JMP::UI::Pager {

    # pass to the constructor
    has @.hits          is required;
    has $.screen        is required;
    has $.title         is required;

    has $.current-page;
    has %!pages;

    method cursor-down {
        return $!current-page.cursor.move-down($!screen)
            unless $!current-page.cursor.at-bottom;
        return if $!current-page.is-last-page;
        # go to the next page
        self.next;
    }

    method cursor-up {
        return $!current-page.cursor.move-up($!screen)
            unless $!current-page.cursor.at-top;

        return if $!current-page.is-first-page;

        # switch to previous page
        $!current-page = %!pages{$!current-page.page-number - 1};

        # render the cursor on the last line of the previous page
        $!current-page.display($!screen, $!current-page.cursor.bottom-line);

    }

    method display-page {
        $!current-page.display($!screen);
    }

    method edit-selected ($editor) {
        
        my $hit = $!current-page.get-selected-hit;
        
        # can't edit those
        return if $hit.isa('JMP::Memory::Command');

        if $hit.isa('JMP::File::HitLater') {
            $hit.find-file-path;     
        }

        return unless $hit.file-path.IO ~~ :e;

        # if it's a command - then execute it?
        $editor.edit($!title, $hit);

        $!current-page.display($!screen, $!current-page.cursor.at-line);
    }

    method next {
        return if $!current-page.is-last-page;
        $!current-page = %!pages{$!current-page.page-number + 1};
        self.display-page;
    }

    method previous {
        return if $!current-page.is-first-page;
        $!current-page = %!pages{$!current-page.page-number - 1};
        self.display-page;
    }

    method TWEAK {

        my $hits-per-page   = JMP::UI::Page::calculate-body-lines-per-page($!screen.rows);
        my $total-pages     = ceiling(@!hits.elems / $hits-per-page);

        for 1 .. $total-pages -> $page-number {
            my @page-hits = @!hits.splice(0, $hits-per-page);
            %!pages{$page-number} = JMP::UI::Page.new(
                                        hits => @page-hits,
                                        :$!title,
                                        :$page-number,
                                        :$total-pages,
                                    );
        }
        $!current-page = %!pages{1};
    }

}
