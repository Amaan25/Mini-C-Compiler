%{
#define YYSTYPE char*
#define YYSTYPE_IS_DECLARED 1
#include "string.h"
#include "y.tab.h"
void id_assignment();
%}
whitespace [ \t\n]+
letter [A-Za-z]
digit [0-9]
id {letter}({letter}|{digit})*
number {digit}+(\.{digit}+)?(E[+\-]?{digit}+)?
%%
{whitespace} { }
:A:          {return '+';}
:S:          {return '-';}
:M:          {return '*';}
:D:          {return '/';}
=            {return '=';}
\(           {return '(';}
\)           {return ')';}
{id}         {id_assignment(); return ID;}
{number}     {id_assignment(); return NUMBER;}
%%

void id_assignment() {
    char* value = malloc(yyleng+1);
    strcpy(value, yytext);
    
    yylval = value;
}

int yywrap() {
    return 1;
}