%{
#include <stdlib.h>
#include "parser.tab.h"
%}
namePattern [a-zA-Z1-9]+
descriptionPattern \"[^\"]*\"
personTagPattern "Per"
containerTagPattern "Con"
systemTagPattern "Sys"
systemBoundaryTagPattern "Boun"
urlSecurePattern "https:\/\/"[^\0;]+
urlNotSecurePattern "http:\/\/"[^\0;]+
includePattern "include"
%%
{includePattern}        { return INCLUDE; }
{urlSecurePattern}      { yylval.valString = strdup(yytext); return URL; }
{urlNotSecurePattern}   { yylval.valString = strdup(yytext); return URL; }
{personTagPattern}      { return PERSON_TAG; }
{containerTagPattern}   { return CONTAINER_TAG; }
{systemTagPattern}      { return SYSTEM_TAG; }
{systemBoundaryTagPattern}  { return SYSTEM_BOUNDARY_TAG; }
{namePattern}           {yylval.valString = strdup(yytext); return NAME; }
{descriptionPattern}    {yylval.valString = strdup(yytext); return DESCRIPTION; }
:                       { return COLON;}
,                       { return COMMA; }
"->"                    { return ARROW; }
"["                     { return OPEN_BRACKET; }
"]"                     { return CLOSE_BRACKET; }
"{"                     { return OPENING_BRACKET; }
"}"                     { return CLOSING_BRACKET; }
";"                     { return EOL; }
\n                      {}
\t                      {}
" "                     {}
.                       { }

%%

