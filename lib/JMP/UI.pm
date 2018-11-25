use v6.d.PREVIEW;
use Terminal::Print;
use Terminal::Print::DecodedInput;
use JMP::UI::Pager;

class Tick { }

class JMP::UI {
        
    has $.title     is required;
    has $.editor    is required;
    has @.hits      is required;    

    has $.pager;
    has $.screen = Terminal::Print.new;

    method TWEAK {

        $!screen.initialize-screen;
        $!pager = JMP::UI::Pager.new(
                        title   =>  $!title,
                        screen  =>  $!screen,
                        hits    =>  @!hits,
                  );
    }
    
    method display {

        my $in-supply   = decoded-input-supply;
        my $timer       = Supply.interval(1).map: { Tick };
        my $supplies    = Supply.merge($in-supply, $timer);

        self.pager.display-page;

        react {
            whenever $supplies -> $_ {
                when Tick {
                    # tock - time passes
                }
                when 'x' | 'X' {
                    $!screen.shutdown-screen;
                    run('reset');
                    exit;
                }
                when 'CursorUp' {
                    self.pager.cursor-up;
                }
                when 'CursorDown' {
                    self.pager.cursor-down;
                }
                when 'CursorRight' | 'PageDown' {
                    self.pager.next;
                }
                when 'CursorLeft' | 'PageUp' {
                    self.pager.previous;
                }
                when $_ ~~ Str and $_.ord == 13 {
                    # the user pressed <ENTER>
                    self.pager.edit-selected($!editor);
                }
            }
        }
    }
}
