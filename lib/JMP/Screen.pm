
use JMP::Screen::Action::EditFile;
use JMP::Screen::Action::EditFileLine;
use JMP::Screen::Page;
use JMP::System;
use Terminal::ANSIColor;

class JMP::Screen {

    has $!content-line-height   = JMP::System.instance.height - 8;    # take 8 for the header and footer
    has $!content-line-width    = JMP::System.instance.width;   
    has %!pages;
    has $.title;

    multi method add-edit-actions ($editor, $search-terms, @hits) {
        my $previous-file-path = '';    
        my @actions;
        for @hits -> $hit {

            if $previous-file-path ne $hit.file-path {
                # outdent new files with an action to open at line 1
                @actions.push(JMP::Screen::Action::EditFile.new(:$editor, file-path => $hit.file-path));
                $previous-file-path = $hit.file-path;
            }
		
            my $context = substr($hit.context, 0, $!content-line-width - 13);   # make allowance for action keys [a]        
	    $context = $context.subst($search-terms, color('inverse') ~ $search-terms ~ color('reset'), :g);
            @actions.push(JMP::Screen::Action::EditFileLine.new(:$editor, :$context, file-path => $hit.file-path, line-number => $hit.line-number));
        }
        self.paginate(@actions);
    }

    # handle going out of bounds with multi methods and type constraints
    multi method display-page ($page-number where * < 1)              { self.display-page(1);             }
    multi method display-page ($page-number where * > %!pages.elems)  { self.display-page(%!pages.elems); }
    multi method display-page ($page-number) {
        return without my $page = %!pages{$page-number};
        say $page.render;
        $.prompt($page);
    }

    submethod get-action-keys-per-page {
        my @action-keys = 'a' ... 'z', 'A' ... 'W';  # reserve [X] for exit
        return @action-keys.splice(0, $!content-line-height);
    }

    submethod new-page($page-number, $total-pages, @actions) {
        return JMP::Screen::Page.new(
                    :$!content-line-height,
                    :$!content-line-width,
                    :$!title, 
                    :$page-number, 
                    :$total-pages,
                    :@actions
                );
    }

    submethod paginate (@actions) {
    
        my @action-keys         = self.get-action-keys-per-page;
        my $actions-per-page    = @action-keys.elems;
        my $total-pages         = ceiling(@actions.elems / $actions-per-page);

        for 1 .. $total-pages -> $page-number {

            my @page-action-keys    = |@action-keys;
            my @page-actions        = @actions.splice(0, $actions-per-page);

            for @page-actions -> $action {
                $action.assign-to-key(@page-action-keys.shift);
            }
            %!pages{$page-number} = self.new-page($page-number, $total-pages, @page-actions);
        }        
    }
    
    submethod prompt ($page) {
        loop {
            my $key-pressed = JMP::System.instance.get-key;
            given $key-pressed {
                when /<[a..zA..W]>/ {
                    $page.get-key-action($key-pressed).do-action;
                }
                when '<' {  self.display-page($page.page-number - 1)    }
                when '>' {  self.display-page($page.page-number + 1)    }
                when 'X' {  say ''; exit;                               }
            }
        }
    }
}
