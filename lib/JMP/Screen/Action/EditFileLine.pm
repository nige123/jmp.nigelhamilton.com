use JMP::Screen::Action;
use JMP::Template;

class JMP::Screen::Action::EditFileLine does JMP::Screen::Action {

    has $.file-path;
    has $.context;
    has $.line-number;
    has $.editor;
    has $.template = q:to"ACTION";
        [[-key-]] ([-line-number-]) [-context-]
    ACTION

    method render {
        my %params = (:$.key, :$.line-number, :$.context);
        return JMP::Template.new.render($.template, %params);
    }

    method do-action {
        $.editor.edit-file($*CWD ~ '/' ~ $.file-path, +$.line-number);
    }

}


