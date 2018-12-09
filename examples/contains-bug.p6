
class Bug {

    has $.bugs = 1;

    method show-bug {    
        say "'; # mismatching quotes
    }

}

Bug.new.show-bug;
