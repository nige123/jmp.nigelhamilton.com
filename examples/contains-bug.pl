package Bug;

use Mojo::Base -base;

has 'bugs' => 1;

sub show_bug {
    
    say "';  # mismatching quotes
}

Bug->new->show_bug;

1;
