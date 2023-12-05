%{
#include <stdlib.h>
#include "parser.tab.h"
%}
namePattern [a-zA-Z1-9]+
descriptionPattern \"[^\"]*\"
personTagPattern "Per"
containerTagPattern "Con"
%%
{personTagPattern}      { return PERSON_TAG; }
{containerTagPattern}   { return CONTAINER_TAG; }
{namePattern}           {yylval.valString = strdup(yytext); return NAME; }
{descriptionPattern}    {yylval.valString = strdup(yytext); return DESCRIPTION; }
:                       { return COLON;}
,                       { return COMMA; }
"->"                    { return ARROW; }
"["                     { return OPEN_BRACKET;}
"]"                     { return CLOSE_BRACKET;}
";"                     { return EOL; }
\n                      {}
\t                      {}
" "                     {}
.                       { }

%%

