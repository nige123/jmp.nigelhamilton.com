#use v6.d.PREVIEW;
use Terminal::Print;
use Terminal::Print::DecodedInput;
use JMP::UI::Pager;

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

        self.pager.display-page;

        my $input = decoded-input-supply();

        react {
            whenever $input -> $_ {
                when 'CursorUp'    | 'k'                    { self.pager.cursor-up;               }
                when 'CursorDown'  | 'j'                    { self.pager.cursor-down;             }
                when 'CursorRight' | 'l' | 'PageDown' | ' ' { self.pager.next;                    }
                when 'CursorLeft'  | 'h' | 'PageUp'         { self.pager.previous;                }
                when 'e' | 'E'                              { self.pager.edit-selected($!editor); }
                when $_ ~~ Str and $_.ord == 13             { self.pager.edit-selected($!editor); }
                when 'x' | 'X' | 'q' | 'Q'                  { $!screen.shutdown-screen; done;     }
            }
        }
    }
}
