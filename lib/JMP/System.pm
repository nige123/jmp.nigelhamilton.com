
#| Operating system abstraction, a singleton
unit class JMP::System;

my $only;
method instance { $only }
method new      { !!!   }

# Default implementation
method width    { chomp(qx[tput cols]).Int     }
method height   { chomp(qx[tput lines]).Int    }
method clear    { shell 'clear'     }
method get-key  { 
    ENTER shell "stty raw -echo";
    LEAVE shell "stty sane";
    $*IN.encoding('ascii');
    return $*IN.getc;
}

# Private subclass for alternate implementation
class Win {
    method width    { qx[powershell.exe -noprofile -command $host.ui.rawui.WindowSize.Width]  }
    method height   { qx[powershell.exe -noprofile -command $host.ui.rawui.WindowSize.Height] }
    method clear    { shell 'cls' }
    method get-key  {
        qx[powershell.exe -noprofile -command $host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp').Character].substr(0,1)
    }
}

$only = ($*SPEC ~~ IO::Spec::Win32 ??
            JMP::System::Win !! JMP::System).bless;


