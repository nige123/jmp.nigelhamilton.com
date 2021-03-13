
class JMP::Memory::Command {

    has $.current-directory is rw;          # the CWD at the time the hit was found
    has $.jmp-command       is rw;          # the original command that generated the hit

    method render {
        return $!current-directory ~ '> ' ~ $!jmp-command;
    }

    method execute {
        chdir($!current-directory);
        shell $!jmp-command;
    }

}
