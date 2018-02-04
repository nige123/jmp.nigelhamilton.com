 
       my @action-keys = 'a' ... 'z', 'A' ... 'W';  # reserve [X] for exit
        say @action-keys.splice(0, 10000).join("\n");

