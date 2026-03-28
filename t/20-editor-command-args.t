use v6;
use lib 'lib';

use Test;
use JMP::Editor;
use JMP::Config;

plan 2;

my $editor = JMP::Editor.new(config => JMP::Config.new);

is-deeply(
    $editor.editor-command-args('path with spaces/file.raku', 12),
    ['nano', '+12', 'path with spaces/file.raku'],
    'default config template keeps quoted filenames as one argument'
);

is-deeply(
    $editor.editor-command-args('lib/JMP/UI.rakumod', 88),
    ['nano', '+88', 'lib/JMP/UI.rakumod'],
    'line number placeholder renders to a separate argv element'
);
