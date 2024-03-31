%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_INSTANCES 100
#define MAX_INSTANCE_LENGTH 100
extern int yylex();
extern int yyabort();
int instance = 0;
char instances[MAX_INSTANCES][MAX_INSTANCE_LENGTH];
FILE *outputFile;

// ERRORS -----------------------------------------------------------------------------------------------
void yyerror(const char* msg) {
    fprintf(stderr, "\033[31mError at declaration number %d:\033[0m %s\n", (instance + 1), msg);
    exit(0);
}

void newInstance(const char* creation, const char* name) {
    char error_msg[200];
    for (int i = 0; i< 100; i++) {
        if(strcmp(instances[i], name) == 0) {
            sprintf(error_msg, "You are trying to create a %s with a name (%s) that is already being used.", creation, name);
            yyerror(error_msg);
        }
    }
    strcpy(instances[instance], name);
}

void missingEOL() {
    char error_msg[200];
    sprintf(error_msg, "Missing missing a ;");
    yyerror(error_msg);
}

void boundaryWithSprite() {
    char error_msg[200];
    sprintf(error_msg, "System Boundaries cannot have sprites assigned");
    yyerror(error_msg);
}

void errorInDeclaration(int ty) {
    char error_msg[200];
    switch (ty) {
        case 1: // Person
            sprintf(error_msg, "This Person declaration is not correct (Per: Name, \"Optional Description\")");
            break;
        case 2: // Container
            sprintf(error_msg, "This Container declaration is not correct (Cont: Name, [content], \"Optional Description\")");
            break;
        case 3: // System
            sprintf(error_msg, "This System declaration is not correct (Sys: Name, \"Optional Description\")");
            break;
        case 4: // System_Boundary
            sprintf(error_msg, "This System Boundary declaration is not correct (Boun: Name, \"Optional Description\" { ... })");
            break;
        case 5: // Relation
            sprintf(error_msg, "This Relation declaration is not correct (From -> Name -> To, \"Optional Description\")");
            break;
        default:
            break;
    }
    yyerror(error_msg);
}
// ------------------------------------------------------------------------------------------------------

// STRING BUILDERS FOR CREATIONS ------------------------------------------------------------------------
char* createPersonString(const char* name, const char* description) {
    newInstance("Person", name);
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
    newInstance("Container", name);
    size_t length = strlen(name) + strlen(name) + strlen(content) + ((description != NULL) ? strlen(description) + 10 : 0) + 16;
    char* result = (char*)malloc(length);
    if (description == NULL) {
        sprintf(result, "Container(%s, \"%s\", \"%s\")", name, name, content);
    } else {
        sprintf(result, "Container(%s, \"%s\", \"%s\", %s )", name, name, content, description);
    }
    return result;
}

char* createSystemString(const char* name, const char* description) {
    newInstance("System", name);
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
    newInstance("System_Boundary", name);
    size_t length = strlen(name) + strlen(name) + strlen(content) + ((description != NULL) ? strlen(description) : 0) + 16;
    char* result = (char*)malloc(length);
    if (description != NULL) {
        sprintf(result, "System_Boundary(%s, \"%s\", %s) {\n%s\n}", name, name, description, content );
    } else {
        sprintf(result, "System_Boundary(%s, \"%s\") {\n%s\n}", name, name, content );
    }
    return result;
}

char* createSpriteString(const char* name) {
    char* concatenated = malloc(strlen(name) + 3); 
    sprintf(concatenated, "\"%s\"", name);
    return concatenated;
}

char* addSprite(const char* body, const char* sprt) {
    if (strlen(body) > 0) {
        char* result = (char*)malloc(strlen (body) + strlen(", ") + strlen(sprt) + 1);
        strncpy(result, body, strlen (body) - 1);
        strcat(result, ", $sprite=");
        strcat(result, sprt);
        strcat(result, ")");
        return result;
    } else {
        return strdup(sprt);
    }
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

// STRING BUILDERS FOR DEFINITIONS ----------------------------------------------------------------------
char* createDefinitionString(char* name, char* url) {
    if ( name == NULL ) {
        char* concatenated = malloc(strlen(url) + 10); 
        sprintf(concatenated, "!include %s", url);
        return concatenated;
    } else {
        char* concatenated = malloc(strlen(name) + strlen(url) + 10); 
        sprintf(concatenated, "!define %s %s", name, url);
        return concatenated;
    }
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
%token INCLUDE 
%token DEFINE
%token SPRITE
%token EQ
%token OPEN_URL
%token CLOSE_URL
%token UP_BAR

%token<valString> UPPERCASE
%token<valString> URL
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
%type<valString> sprite
%type<valString> definition

%start S

%%
S: input_list

// Handle the input line
input_list:
      input_list input EOL  { instance++;   }
    | input_list input      { missingEOL(); }
    | input EOL             { instance++;   }
    | input                 { missingEOL(); }

input: 
      creation      { fprintf(outputFile, "%s\n", $1); }
    | relation      { fprintf(outputFile, "%s\n", $1); }
    | definition    { fprintf(outputFile, "%s\n", $1); }
    ;

// Handle definitions and includes
definition:
      INCLUDE COLON URL     { $$ = createDefinitionString(NULL, $3); }
    | DEFINE COLON NAME URL { $$ = createDefinitionString($3, $4);   }


// Handle the creation of objects
creation:
      person                        { $$ = $1;                }
    | person UP_BAR sprite          { $$ = addSprite($1, $3); }
    | container                     { $$ = $1;                }
    | container UP_BAR sprite       { $$ = addSprite($1, $3); }
    | system                        { $$ = $1;                }
    | system UP_BAR sprite          { $$ = addSprite($1, $3); }
    | system_boundary               { $$ = $1;                }
    | system_boundary UP_BAR sprite { boundaryWithSprite();   }
    ;

// Handle the instanciation of relations between objects
relation: 
      NAME ARROW NAME ARROW NAME                     { $$ = createRelationString($1, $5, $3, NULL); }
    | NAME ARROW NAME ARROW NAME COMMA DESCRIPTION   { $$ = createRelationString($1, $5, $3, $7);   }
    | DESCRIPTION COMMA NAME ARROW NAME ARROW NAME   { errorInDeclaration(5);                       } // Error in Declaration
    ;

// Handle creation of a Person
person:
      PERSON_TAG COLON NAME                      { $$ = createPersonString($3, NULL); } // Person
    | PERSON_TAG COLON NAME COMMA DESCRIPTION    { $$ = createPersonString($3, $5);   } // Person & Description
    | PERSON_TAG COLON DESCRIPTION COMMA NAME    { errorInDeclaration(1);             } // Error in declaration
    ;

// Handle creation of a Container
container:
      CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET                   { $$ = createContainerString($3, $6, NULL); } // Container
    | CONTAINER_TAG COLON NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET COMMA DESCRIPTION { $$ = createContainerString($3, $6, $9);   } // Container  & Description
    | CONTAINER_TAG COLON DESCRIPTION COMMA NAME COMMA OPEN_BRACKET container_content CLOSE_BRACKET { errorInDeclaration(2);                    } // Error in declaration
    | CONTAINER_TAG COLON OPEN_BRACKET container_content CLOSE_BRACKET COMMA NAME COMMA DESCRIPTION { errorInDeclaration(2);                    } // Error in declaration
    | CONTAINER_TAG COLON OPEN_BRACKET container_content CLOSE_BRACKET COMMA DESCRIPTION COMMA NAME { errorInDeclaration(2);                    } // Error in declaration
    ;

container_content:
    container_content COMMA NAME { 
        char* concatenated = malloc(strlen($1) + strlen($3) + 3); 
        sprintf(concatenated, "%s, %s", $1, $3);
        $$ = concatenated;
    }
    | NAME { $$ = strdup($1); }

// Handle creation of a System
system:
      SYSTEM_TAG COLON NAME                   { $$ = createSystemString($3, NULL); } // System
    | SYSTEM_TAG COLON NAME COMMA DESCRIPTION { $$ = createSystemString($3, $5);   } // System & Description
    | SYSTEM_TAG COLON DESCRIPTION COMMA NAME { errorInDeclaration(3);             } // Error in declaration


// Handle creation of a System Boundary
system_boundary:
     SYSTEM_BOUNDARY_TAG COLON NAME OPENING_BRACKET system_content CLOSING_BRACKET                    { $$ = createSystemBoundaryString($3, NULL, $5); } // System
    | SYSTEM_BOUNDARY_TAG COLON NAME COMMA DESCRIPTION OPENING_BRACKET system_content CLOSING_BRACKET { $$ = createSystemBoundaryString($3, $5, $7);   } // System & Description
    | SYSTEM_BOUNDARY_TAG COLON DESCRIPTION COMMA NAME OPENING_BRACKET system_content CLOSING_BRACKET { errorInDeclaration(4);                         } // Error in Declaration
    ;
system_content:
      system_content creation EOL { 
        char* concatenated = malloc(strlen($1) + strlen($2) + 3); 
        sprintf(concatenated, "%s\n\t%s", $1, $2);
        $$ = concatenated;
    }
    | creation EOL { 
        char* concatenated = malloc(strlen($1) + 3); 
        sprintf(concatenated, "\t%s", $1);
        $$ = concatenated;
    }
    | system_content creation { missingEOL(); }
    | creation                { missingEOL(); }
    ;

// Handle creation of a Sprite
sprite: 
    SPRITE EQ NAME { $$ = createSpriteString($3); }
%%

int main() {
    char filename[20] = "C4_Result.pu";
    char newFilename[20];
    int count = 1;

    // Check if the file already exists
    while ((outputFile = fopen(filename, "r")) != NULL) {
        fclose(outputFile);
        // If it exists, create a new filename with a number
        snprintf(newFilename, sizeof(newFilename), "C4_Result_%d.pu", count);
        count++;
        strcpy(filename, newFilename); // Update the filename for the next iteration
    }

    // Create or open the file for writing
    outputFile = fopen(filename, "w");
    if (outputFile == NULL) {
        fprintf(stderr, "Error opening file for writing.\n");
        return 1;
    }
    fprintf(outputFile, "@startuml C4_Elements\n!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml\n");
    yyparse();
    fprintf(outputFile, "@enduml");
    printf("\033[0;32mCongratulations! Your file was correctly parsed to PlantUML\033[0m\n");
    return 0; 
}
