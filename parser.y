%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylex();
extern int yyabort();
int line = 1;
FILE *outputFile;
void yyerror(const char* msg) {
    fprintf(stderr, "\033[31mError na liña %d:\033[0m %s\n", line, msg);
    exit(0);
}

%}

%union {
    char* valString;
    int valInt;
}


%token EOL
%token ARROW
%token COLON
%token COMMA
%token PERSON_TAG
%token CONTAINER_TAG
%token SYSTEM_TAG
%token OPENING_BRACKET
%token CLOSING_BRACKET
%token OPEN_BRACKET
%token CLOSE_BRACKET

%token<valString> NAME
%token<valString> DESCRIPTION
%type <valString> container_content

%start S

%%
S: input_list

// Handle the input line

input_list:
    input_list input {}
    | input {}

input: 
      creation EOL {}
    | relation EOL {}
    ;

// Handle the creation of objects
creation:
    | person {}
    | container {}
    | system {}
    ;

// Handle the instanciation of relations between objects
relation: 
     NAME ARROW NAME ARROW NAME {printf("Relacion!");}
    | NAME ARROW NAME ARROW NAME COMMA DESCRIPTION {fprintf(outputFile, "Rel(%s, %s, \"%s\", %s)\n",$1, $5, $3, $7);}
    ;

// Creation of a Person
person:
     PERSON_TAG COLON NAME  { fprintf(outputFile, "Person(%s, \"%s\")\n",$3, $3); }
    | PERSON_TAG COLON NAME COMMA DESCRIPTION  { fprintf(outputFile, "Person(%s, \"%s\", %s)\n",$3, $3, $5); } // Person & Description
    ;

// Creation of a Container
container:
    CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET {fprintf(outputFile, "Container(%s, \"%s\", \"%s\")\n",$3, $3, $6);} // Container
    | CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET COMMA DESCRIPTION {fprintf(outputFile, "Container(%s, \"%s\", \"%s\", %s)\n",$3, $3, $6, $9);} // Container  & Description
    ;

container_content:
    container_content COMMA NAME { 
        char* concatenated = malloc(strlen($1) + strlen($3) + 3); // +3 for comma, space, and null terminator
        sprintf(concatenated, "%s, %s", $1, $3);
        $$ = concatenated;
    }
    | NAME { $$ = strdup($1); }

// Creation of a System Boundary
system:
     SYSTEM_TAG NAME system_content OPENING_BRACKET system_content CLOSING_BRACKET {} // System
    | SYSTEM_TAG NAME COMMA DESCRIPTION OPENING_BRACKET system_content CLOSING_BRACKET {} // System & Description
    ;
system_content:
     system_content COMMA creation {}
    | creation {}
    ;
%%

int main() {
    outputFile = fopen("C4_Result.pu", "w");
    fprintf(outputFile, "@startuml C4_Elements\n!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml\n");
    yyparse();
    return 0; 
}
