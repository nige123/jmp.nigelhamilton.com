use OO::Monitors;
unit monitor Terminal::UI::Input;
use Terminal::UI::Utils;
use Terminal::ANSI;
use Log::Async;
use NativeCall;

logger.untapped-ok = True;
method pod { $=pod }

#| read(2) on a file descriptor: returns whatever the terminal has, up to $n bytes
sub c-read(int32 $fd, Blob $buf, size_t $n --> ssize_t) is native is symbol('read') { * }

#| TTY from which we are reading input
has $.tty;

method !maybe-init {
  return False unless $*IN.t;
  self.init without $!tty;
  return True;
}

#| Initialize input (called implicity if necessary)
method init {
  shell "stty raw -echo -icanon min 1 time 1";
  if $*RAKU.compiler.name eq 'Raku++' {
    # Raku++ 4.0.1: a handle opened on /dev/tty never delivers input, and
    # $*IN.read(N) waits for all N bytes; read(2) on standard input returns
    # what the terminal has, which is what an escape sequence needs
    $!tty = 'stdin';
  }
  else {
    $!tty = open("/dev/tty");
  }
}

#| Stop reading from the tty, and reset things
method shutdown {
  # standard input stays open: the editor launched next inherits it
  if $!tty.defined && $!tty !~~ Str {
    $!tty.close;
  }
  shell "stty sane";
  $!tty = Nil;
}

#| Get a single key, and optionally debug the bytes into a character.  Escape sequences are parsed by Terminal::ANSI::parse-input.
method get-key(Bool :$decode = True) {
  self!maybe-init or return;
  my $got;
  if $!tty ~~ Str {
    my $buf = Buf.new(0 xx 10);
    my $n = c-read(0, $buf, 10);
    abort "could not read the terminal" if $n < 0;
    $got = $buf.subbuf(0, $n);
  }
  else {
    $got = try $!tty.read(10);
    abort "$!" if $!;
  }
  return $got unless $decode;
  my $c = $got.decode;
  return parse-input($c) // $c;
}

=NAME Terminal::UI::Input -- Keyboard input

=begin DESCRIPTION

Get keyboard input.

=end DESCRIPTION
