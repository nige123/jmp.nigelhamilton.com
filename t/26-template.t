use v6;
use lib 'lib';

use Test;
use JMP::Template;

plan 8;

my $template = JMP::Template.new;

is $template.render('hello [-name-]', { name => 'world' }), 'hello world', 'substitutes a token';
is $template.render('[-a-] and [-b-]', { a => 'x', b => 'y' }), 'x and y', 'substitutes several tokens';
is $template.render('[-unknown-]', { other => 'value' }), '[-unknown-]', 'leaves an unknown token unchanged';
is $template.render('[-token-]', {}), '[-token-]', 'leaves a token unchanged with no params';
is $template.render('no tokens here', { a => 'b' }), 'no tokens here', 'passes text without tokens through';
is $template.render('', { a => 'b' }), '', 'renders an empty string';
is $template.render('[-x-] [-x-]', { x => 'hello' }), 'hello hello', 'substitutes a repeated token';
is $template.render('before [-token-] after', { token => '' }), 'before  after', 'substitutes an empty value';
