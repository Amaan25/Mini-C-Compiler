%{
	#include<stdio.h>
	#include "y.tab.h"
	struct node{
		char* identifier;
		int scope;
		char* type; 
		int Line_Number; 
		int value;
		struct node* next_Node; 
	};
	typedef struct node Node;
%}

%union {
    int value;
    struct node * info_for_creation;
}


%type <value> ArithmeticExpression

%type <info_for_creation> I

%token NUMBER IF CLOSEBRACKET OPENBRACKET ELSE ID INT STRLT CURLYOPEN CURLYCLOSE ASSIGN_OP FOR SEMICOLON LESS_THAN_OP GREATER_THAN_OP LESS_THAN_EQUAL_OP GREATER_THAN_EQUAL_OP COMPARSION_OP

%left '+' '-'
  
%left '*' '/' '%'
  
%left '(' ')'

%%


StatementList : Statement
              | Assignment_statement
              | FOR_statement
              | declaration_statement
              |
              ;

I: ID			{
				struct node * t = (struct node *)yylval.info_for_creation;
				$$ = t;
			}
;

declare: INT I ASSIGN_OP ArithmeticExpression SEMICOLON {
					struct node * temp = $2;
					if (strlen(temp->type) != 0)
					{
						printf("Variable redeclared...\n");
						exit(0);
					}
					modify(temp->identifier,temp->scope,"INT",temp->Line_Number,$4);
					printf("\nTOKEN:%s \tADDR IN SYMBOL TABLE:%p \tLINE OF DECLARATION: %d \tTYPE: %s\t VALUE:%d\n",temp->identifier,temp,temp->Line_Number,temp->type,temp->value);}
| INT I SEMICOLON {
					struct node * temp = $2;
					if (strlen(temp->type) != 0)
					{
						printf("Variable redeclared...\n");
						exit(0);
					}
					modify(temp->identifier,temp->scope,"INT",temp->Line_Number,temp->value);
					printf("\nTOKEN:%s \tADDR IN SYMBOL TABLE:%p \tLINE OF DECLARATION: %d \tTYPE: %s\t VALUE:%d\n",temp->identifier,temp,temp->Line_Number,temp->type,temp->value);}
;

declaration_statement: declare StatementList
;

if_statement: IF OPENBRACKET IF_COND CLOSEBRACKET CURLYOPEN StatementList CURLYCLOSE ELSE_statement {
                  printf("Parsed if part\n");
            }
| IF OPENBRACKET ID ASSIGN_OP ArithmeticExpression CLOSEBRACKET CURLYOPEN StatementList CURLYCLOSE ELSE_statement {
                  printf("Parsed if part\n");
            }
;


Statement :  if_statement StatementList
;
          
ELSE_statement: ELSE CURLYOPEN StatementList CURLYCLOSE {printf("Parsed else part\n");}
| {printf("Else not there\n");}
;


ArithmeticExpression : NUMBER                  {$$ = yylval.value;}
                     | I 			 {
							if (strlen($1->type) != 0)
							{
								$$ = $1->value;
							}
							else
							{
								printf("Error: Variable not declared...\n");
								exit(0);
							}
						}
                     | ArithmeticExpression '+' ArithmeticExpression { $$ = $1+$3; }
                     | ArithmeticExpression '-' ArithmeticExpression { $$ = $1-$3; }
                     | ArithmeticExpression '*' ArithmeticExpression { $$ = $1*$3; }
                     | ArithmeticExpression '/' ArithmeticExpression { $$ = $1/$3; }
                     | OPENBRACKET ArithmeticExpression CLOSEBRACKET { $$ = $2; }
                     ;
                     
assigning_part: I ASSIGN_OP ArithmeticExpression 				{
											if (strlen($1->type) != 0)
											{
												$1->value = $3;
												printf("Changed value to: %d\n",$1->value);
											}
											else
											{
												printf("Error: Variable not declared...\n");
												exit(0);
											}};
Assignment_statement: assigning_part SEMICOLON StatementList
;

IF_COND: RELATIONAL_statement
| ArithmeticExpression
;

RELATIONAL_statement: ArithmeticExpression LESS_THAN_OP ArithmeticExpression			{if ($1 >= $3)
												{
													printf("Condition not met...\n");
												}}
| ArithmeticExpression GREATER_THAN_OP ArithmeticExpression					{if ($1 <= $3)
												{
													printf("Condition not met...\n");
												}}
| ArithmeticExpression LESS_THAN_EQUAL_OP ArithmeticExpression				{if ($1 > $3)
												{
													printf("Condition not met...\n");
												}}
| ArithmeticExpression GREATER_THAN_EQUAL_OP ArithmeticExpression				{if ($1 < $3)
												{
													printf("Condition not met...\n");
												}}
| ArithmeticExpression COMPARSION_OP ArithmeticExpression					{if ($1 != $3)
												{
													printf("Condition not met...\n");
												}}
;

INITILATION_STATEMENT: assigning_part
|;

CHECK_STATEMENT: assigning_part
| RELATIONAL_statement
;

INCREMENT_STATEMENT: assigning_part
|;

for_statement: FOR OPENBRACKET INITILATION_STATEMENT SEMICOLON CHECK_STATEMENT SEMICOLON INCREMENT_STATEMENT CLOSEBRACKET CURLYOPEN StatementList CURLYCLOSE
;

FOR_statement: for_statement StatementList
;

%%
 
void main()
{
	init_symbol();					//to initialise symbol table
	init_symbol_table_with_keywords();		//to initialise table with keywords
	/* yyin and yyout as pointer
	of File type */
	extern FILE *yyin, *yyout;

	/* yyin points to the file input.txt
	and opens it in read mode*/
	yyin = fopen("Input.c", "r");		//Input file



	/* yyout points to the file output.txt
	and opens it in write mode*/
	
	 FILE *fptr;
	

	fptr = fopen("Output_Of_Program.txt", "w");		//Output file
	if (fptr == NULL)
	{
		printf("Error opening file!\n");
		exit(0);
	}
	else
	{
		fprintf(fptr, "Token ID		Token Value\n");
		fprintf(fptr, "--------		------------\n\n");
		
		fclose(fptr);
	}	


	yyout = fopen("Output_Of_Program.txt", "a");
	yyparse();
}

void yyerror()
{
	printf("Error in parsing\n");
}
