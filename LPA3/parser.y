%{
#include <ctype.h>
#include <stdio.h>
#define YYSTYPE char*
#define YYSTYPE_IS_DECLARED 1
int yylex(void);
void yyerror(char *error_string);
int counter = 1;
char* print_automated(char* e1, char op, char* e2);
%}
%token NUMBER ID
%right '+' '-'
%right '*' '/'
%%
program_start : ID '=' expr '+' expr { printf("x = %s + %s;", $5, $3); }
|ID '=' expr '-' expr 		     { printf("x = %s - %s;", $5, $3); }
|ID '=' expr '*' expr 		     { printf("x = %s * %s;", $5, $3); }
|ID '=' expr '/' expr                { printf("x = %s / %s;", $5, $3); }
|ID '=' '(' expr ')' 	             { printf("x = %s;", $4); }
|ID '=' NUMBER
|ID '=' ID
;

expr : expr '+' expr { $$ = print_automated($3,'+',$1); }
| expr '-' expr      { $$ = print_automated($3, '-', $1); }
| expr '*' expr      { $$ = print_automated($3, '*',  $1); }
| expr '/' expr      { $$ = print_automated($3, '/', $1); }
| '(' expr ')'       { $$ = $2; }
| NUMBER
| ID
;
%%
char* print_automated(char* e1, char op,char* e2) {
    char* t = malloc(50);

    // concat number to 't' -> example: t1
    sprintf(t, "t%d",counter);

    // print three-address-code -> example: t1 = 4/3
    printf("%s = %s %c %s;\n", t, e1, op, e2);

    // increment for next 't'
    counter++;

    return t;
}

void yyerror(char *error_string){
    printf("Error: %s\n", error_string);
}

int main()
{
    if (yyparse() != 0)
        printf( "Error While Parsing!!!\n");

    return 0;
}
