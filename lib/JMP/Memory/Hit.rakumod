use JMP::File::Hit;

class JMP::Memory::Hit is JMP::File::Hit {

    method render {
        return '    ' ~ self.relative-path ~ ' (' ~ self.line-number ~ ') ' ~ self.matching-text
            if self.matching-text;
        return '    ' ~ self.relative-path ~ ' (' ~ self.line-number ~ ')';
    }

}
