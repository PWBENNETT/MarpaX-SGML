package MarpaX::SGML::Concrete::Default;

our $Terminals=<<'MARPA';
RE ~ [\x{D}]
RS ~ [\x{A}]
SPACE ~ [\x{20}]
SEPCHAR ~ [\x{9}]
LCLetter ~ [a-z]
UCLetter ~ [A-Z]
Digit ~ [0-9]
lit ~ ["]
lita ~ [']
Squo ~ [']
stago ~ '<'
tagc ~ '>'
neto ~ '/'
netc ~ '/'
etago ~ '</'
pio ~ '<?'
pic ~ '?>'
dtgo ~ '['
dtgc ~ ']'
mdo ~ '<!'
mdc ~ '>'
dso ~ '['
dsc ~ ']'
msc ~ ']]'
shortref ~ '&#TAB;'
         | '&#RE;'
         | '&#RS;'
         | '&#RS;B'
         | '&#RS;&#RE;'
         | '&#RS;B&#RE;'
         | 'B&#RE;'
         | '&#SPACE;'
         | 'BB'
         | '"'
         | '#'
         | '%'
         | Squo
         | '('
         | ')'
         | '*'
         | '+'
         | ','
         | '-'
         | '--'
         | ':'
         | ';'
         | '='
         | '@'
         | '['
         | ']'
         | '^'
         | '_'
         | '{'
         | '|'
         | '}'
         | '~'
vi ~ '='
plus ~ '+'
minus ~ '-'
slashslash ~ '//'
LCNMCHAR ~ '-'
         | '.'
ero ~ '&'
pero ~ '%'
refc ~ ';'
cro ~ '&#'
grpo ~ '('
grpc ~ ')'
Special ~ '('
        | ')'
        | '+'
        | ','
        | '-'
        | '.'
        | '/'
        | ':'
        | '='
        | '?'
        | Squo
com ~ '--'
rni ~ '#'
and ~ '&'
or ~ '|'
seq ~ ','
opt ~ '?'
rep ~ '*'
Ee ~ bless => EE
Nothing ~
MARPA

1;
