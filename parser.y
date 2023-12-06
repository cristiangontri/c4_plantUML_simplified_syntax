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

// STRING BUILDERS FOR CREATIONS ------------------------------------------------------------------------
char* createPersonString(const char* name, const char* description) {
    size_t length = strlen(name) + strlen(name) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "Person(%s, \"%s\", %s)", name, name, description);
    } else {
        sprintf(result, "Person(%s, \"%s\")", name, name);
    }
    return result;
}

char* createContainerString(const char* name, const char* content, const char* description) {
    size_t length = strlen(name) + strlen(name) + strlen(content) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "Container(%s, \"%s\", \"%s\")", name, name, content);
    } else {
        sprintf(result, "Container(%s, \"%s\", \"%s\", \"%s\" )", name, name, content, description);
    }
    return result;
}

char* createSystemString(const char* name, const char* description) {
    size_t length = strlen(name) + strlen(name) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "System(%s, \"%s\", %s)", name, name, description);
    } else {
        sprintf(result, "System(%s, \"%s\")", name, name);
    }
    return result;
}

char* createSystemBoundaryString(const char* name, const char* description, const char* content) {
    size_t length = strlen(name) + strlen(name) + strlen(content) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "System_Boundary(%s, \"%s\", %s) {\n%s\n}\n", name, name, description, content );
    } else {
        sprintf(result, "System_Boundary(%s, \"%s\") {\n%s\n}\n", name, name, content );
    }
    return result;
}
// ------------------------------------------------------------------------------------------------------


// STRING BUILDERS FOR RELATIONS ------------------------------------------------------------------------
char* createRelationString(const char* from, const char* to, const char* name, const char* description) {
    size_t length = strlen(name) + strlen(name) + strlen(from) + strlen(to) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "Rel(%s, %s, \"%s\", %s)", from, to , name, description);
    } else {
        sprintf(result, "Rel(%s, %s, \"%s\")", from, to , name);
    }
    return result;
}
// ------------------------------------------------------------------------------------------------------

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
%token SYSTEM_BOUNDARY_TAG
%token OPENING_BRACKET
%token CLOSING_BRACKET
%token OPEN_BRACKET
%token CLOSE_BRACKET

%token<valString> NAME
%token<valString> DESCRIPTION
%type <valString> container_content
%type<valString> person
%type<valString> container
%type<valString> system
%type<valString> system_boundary
%type<valString> system_content
%type<valString> creation
%type<valString> relation


%start S

%%
S: input_list

// Handle the input line

input_list:
    input_list input {}
    | input {}

input: 
      creation EOL { fprintf(outputFile, "%s\n", $1); }
    | relation EOL { fprintf(outputFile, "%s\n", $1); }
    ;

// Handle the creation of objects
creation:
      person { $$ = $1; }
    | container { $$ = $1; }
    | system { $$ = $1; }
    | system_boundary { $$ = $1; }
    ;

// Handle the instanciation of relations between objects
relation: 
     NAME ARROW NAME ARROW NAME {
        $$ = createRelationString($1, $5, $3, NULL);
     }
    | NAME ARROW NAME ARROW NAME COMMA DESCRIPTION {
        $$ = createRelationString($1, $5, $3, $7);
    }
    ;

// Creation of a Person
person:
     PERSON_TAG COLON NAME  { 
        $$ = createPersonString($3, NULL);
    }
    | PERSON_TAG COLON NAME COMMA DESCRIPTION  {
        $$ = createPersonString($3, $5);
    } // Person & Description
    ;

// Creation of a Container
container:
    CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET {
        $$ = createContainerString($3, $6, NULL);
    } // Container
    | CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET COMMA DESCRIPTION {
        $$ = createContainerString($3, $6, $9);
    } // Container  & Description
    ;

container_content:
    container_content COMMA NAME { 
        char* concatenated = malloc(strlen($1) + strlen($3) + 3); 
        sprintf(concatenated, "%s, %s", $1, $3);
        $$ = concatenated;
    }
    | NAME { $$ = strdup($1); }

system:
    SYSTEM_TAG COLON NAME {
        $$ = createSystemString($3, NULL);
    }
    | SYSTEM_TAG COLON NAME COMMA DESCRIPTION {
        $$ = createSystemString($3, $5);
    }


// Creation of a System Boundary
system_boundary:
     SYSTEM_BOUNDARY_TAG COLON NAME OPENING_BRACKET system_content CLOSING_BRACKET {
        $$ = createSystemBoundaryString($3, NULL, $5);
    } // System
    | SYSTEM_BOUNDARY_TAG COLON NAME COMMA DESCRIPTION OPENING_BRACKET system_content CLOSING_BRACKET {
        $$ = createSystemBoundaryString($3, $5, $7);
    } // System & Description
    ;
system_content:
     system_content COMMA creation {
        char* concatenated = malloc(strlen($1) + strlen($3) + 3); 
        sprintf(concatenated, "%s\n\t%s", $1, $3);
        $$ = concatenated;
     }
    | creation { 
        char* concatenated = malloc(strlen($1) + 3); 
        sprintf(concatenated, "\t%s", $1);
        $$ = concatenated;
    }
    ;
%%

int main() {
    outputFile = fopen("C4_Result.pu", "w");
    fprintf(outputFile, "@startuml C4_Elements\n!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml\n");
    yyparse();
    fprintf(outputFile, "@enduml");
    return 0; 
}
