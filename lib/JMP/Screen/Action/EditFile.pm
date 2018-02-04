
use JMP::Screen::Action;
use JMP::Template;

class JMP::Screen::Action::EditFile does JMP::Screen::Action {

    has $.editor;
    has $.file-path;
    
    has $.template = q:to"ACTION";
    [[-key-]] [-file-path-]
    ACTION

    method render {
        my %params = (:$.file-path, :$!key);
        return JMP::Template.new.render($.template, %params);
    }

    method do-action {
        # open file with an absolute path - start at line 1
        $.editor.edit-file($*CWD ~ '/' ~ $.file-path, 1);
    }

}

