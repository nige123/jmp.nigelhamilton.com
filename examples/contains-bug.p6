
class Bug {

    has $.bugs = 1;

    method show-bug {    
        say ";     # no closing quote
    }

}

Bug.new.show-bug;
