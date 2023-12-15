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
urlPattern <[^;<>]+>
includePattern "include"
spritePattern "sprite"
definePattern "define"

%%
{definePattern}         { return DEFINE; }
{spritePattern}         { return SPRITE; }
{includePattern}        { return INCLUDE; }
{urlPattern}            { 
                            yytext[strlen(yytext) - 1] = '\0';
                            yylval.valString = strdup(yytext + 1); 
                            return URL;  return URL; 
                        }
{personTagPattern}      { return PERSON_TAG; }
{containerTagPattern}   { return CONTAINER_TAG; }
{systemTagPattern}      { return SYSTEM_TAG; }
{systemBoundaryTagPattern}  { return SYSTEM_BOUNDARY_TAG; }
{namePattern}           {yylval.valString = strdup(yytext); return NAME; }
{descriptionPattern}    {yylval.valString = strdup(yytext); return DESCRIPTION; }
:                       { return COLON;}
,                       { return COMMA; }
"|"                     { return UP_BAR; }
"="                     { return EQ; }
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

