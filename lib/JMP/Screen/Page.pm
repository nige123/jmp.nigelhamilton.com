use JMP::Template;

class JMP::Screen::Page {

    has @.actions;

    has Int $.page-number = 1;    
    has Int $.content-line-height;
    has Int $.content-line-width;
    has Str $.title;
    has Int $.total-pages;
    
#    has $!rendered-page = '';

    method get-key-action ($key-pressed) {
        # search through all the actions - does one match the key pressed?
        # | flatten the element found in the list
        return |@!actions.grep({ $_.does-action($key-pressed) });
    }

    method render {

        has $template = q:to"PAGE";

        [-title-]                                [-page-number-] of [-total-pages-]
        [-rule-]
        [-contents-]
        [-rule-]        
        [<] Previous         e[X]it            [>] Next
        PAGE

        my $rule = '_' x $!content-line-width;
    
        return JMP::Template.new.render($!template, { :$!title, :$!page-number, :$!total-pages, :$rule, contents => self.render-actions });
        
    }

    method render-actions {
         
        # iterate through all the actions >> call render on them 
        # and [~] concatentate them together 
        my $rendered-actions    = [~](@!actions>>.render);

        # iterate through all the actions >> call line-height on them
        # and [+] sum the line heights
        my $lines-used          = [+](@!actions>>.line-height);

        # if there are more available lines - add padding
        my $vertical-padding    = "\n" x $!content-line-height - $lines-used;
        $rendered-actions ~= $vertical-padding;
        return $rendered-actions;

    }

}
