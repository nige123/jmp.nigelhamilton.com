
# declare a role - the implementation and interface is shared with classes that "do" the role
role JMP::Screen::Action {

    # all actions will need a key and takes up a height in lines on the screen
    has $.key           = '';
    has $.line-height   = 1;

    # assign a key depending on where it appears on the screen
    method assign-to-key($key) {
        $!key = $key;
    }
    method does-action($key) returns Bool {
        return $key eq $.key;
    }
    method do-action { ... }
    method render    { ... }

}
