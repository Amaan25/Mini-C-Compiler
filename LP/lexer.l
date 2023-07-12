/* Assignment done by -

BT20CSE083 - Vaibhav Siddodhan Mokale

BT20CSE125 - Suraj Wasudeo Wamne

*/



/* To Run this Assignment you need Input.txt file and deploy.sh, deploy.sh will automatically open a output file */




/* Instructions:
1. Run:  chmod u+x deploy.sh

2. Run: ./deploy.sh

first will give permission to deploy.sh file and second will run that file 
*/




/* Note this lexer takes input from Input.txt file and produces a output file name as Output_Of_Program.txt. So if you don`t have Input.txt file, please consider to make one*/


/* In this code, we also made a symbol table.*/



%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	
	//extern int yylval;
	#define SIZE 101
	int entry_count = 0;
	int scope = 0;
	int line = 1;
	
	
	char prev_token[100] = {'\0'};
	struct node{
		char* identifier;
		int scope;
		char* type; 
		int Line_Number; 
		int value;
		struct node* next_Node; 
	};
	typedef struct node Node;
	typedef struct symbol {
		Node *header[SIZE];
	} symbol;

	// Declare the yylval variable
	extern YYSTYPE yylval;
	
	Node * define_resolver(char * id, int line, int scope);
	void init_symbol();
	void init_symbol_table_with_keywords();
	Node* init_Node(char * key, int value, char * type, int Line_Number, int val);
	unsigned int hash(char * id);
	int insert(char * id, int scope, char * Type, int Line_Number, int value);
	int modify(char* id, int s, char* t, int l, int val);
	Node * lookup(char * id, int scope);
	int remove_symbol(char * id);
	void insert_into_symbol_table(char * id, int scope, char * Type, int Line_Number, int val);
	int count_new_line(char * t);
	void function_handler(char * id, int scope, char * Type, int Line_Number);
	
	
	//Instance of symbol table
	symbol s_table;
	char * prev = prev_token;

%}

%%

for {fprintf(yyout,"Keyword:		%s\n",yytext);
	return FOR;}

"<" {fprintf(yyout,"Keyword:		%s\n",yytext);
	return LESS_THAN_OP;}
	
">" {fprintf(yyout,"Keyword:		%s\n",yytext);
	return GREATER_THAN_OP;}
	
"<=" {fprintf(yyout,"Keyword:		%s\n",yytext);
	return LESS_THAN_EQUAL_OP;}
		
">=" {fprintf(yyout,"Keyword:		%s\n",yytext);
	return GREATER_THAN_EQUAL_OP;}
		
		
"==" {fprintf(yyout,"Comparison operator:	%s\n",yytext); 
	return COMPARSION_OP;}
	

else" "if|>|<|"void"|"char"|switch|break|while|"for"|double {fprintf(yyout,"INVALID TOKENS:	%s\n",yytext);}
									

"//".*     {fprintf(yyout,"Single Line comment:	%s\n", yytext);
		strcpy(prev,"");}

"/*"(.*[\n].*)*"*/" {fprintf(yyout,"Multi Line comment:	%s\n", yytext);
			line = line + count_new_line(yytext);
			strcpy(prev,"");}

[{] {scope++;
	fprintf(yyout,"\n\n------ENTERED NEW SCOPE-------\n");
	strcpy(prev,"");
	return CURLYOPEN;}

[}] {scope--;
	fprintf(yyout,"\n------EXITED NEW SCOPE-------\n\n");
	strcpy(prev,"");
	return CURLYCLOSE;
	//Delete existing scope records from symbol table (to be done in Syntax analyser)
	}
	
"(" 	{strcpy(prev,"");
	return OPENBRACKET;}

")" 	{strcpy(prev,"");
	return CLOSEBRACKET;}

["].*["] {return STRLT;}

[ \t\r]+ {}

[\n] {line++;
	strcpy(prev,"");}

"main()" {insert_into_symbol_table(yytext,scope,"reserved keyword",line,0);
					Node * t = lookup(yytext,scope);
					printf("\nTOKEN:%s \tADDR IN SYMBOL TABLE:%p \tLINE OF DECLARATION: %d \tTYPE: %s\n",t->identifier,t,t->Line_Number,t->type);
					fprintf(yyout,"Function-Name:		%s\n",yytext);
					strcpy(prev,"");}



#include<.*> {fprintf(yyout,"Preprocessor :		%s\n",yytext);}

#define.* {	fprintf(yyout,"Macros:		%s\n",yytext);
		Node * t = define_resolver(yytext,line,scope);
		printf("\nTOKEN:%s \tADDR IN SYMBOL TABLE:%p \tLINE OF DECLARATION: %d \tTYPE: %s\n",t->identifier,t,t->Line_Number,t->type);}

; {fprintf(yyout,"Semi-colon:		%s\n",yytext);
	return SEMICOLON;}

int {fprintf(yyout,"Keyword:		%s\n",yytext);
	strcpy(prev,yytext);
	return INT;}

if {fprintf(yyout,"Keyword:		%s\n",yytext);
	strcpy(prev,"");
	return IF;}
	
else {fprintf(yyout,"Keyword:		%s\n",yytext);
	strcpy(prev,"");
	return ELSE;}

return {fprintf(yyout,"Keyword:		%s\n",yytext);
	strcpy(prev,"");}

[a-z|A-Z|_][a-z|A-Z|0-9|_]{0,31} {	insert_into_symbol_table(yytext,scope,"",line,2147483647);
					fprintf(yyout,"IDENTIFIER:		%s\n",yytext);
					Node * t = lookup(yytext,scope);
					yylval.info_for_creation = (struct node *)t;
					return ID;
					}
					

[0-9]+ 			{	fprintf(yyout,"Literal:		%s\n",yytext);
					YYSTYPE l;
					l.value = atoi(yytext); 
					yylval = l;
					return NUMBER;}

[=] {fprintf(yyout,"Assigment operator:	%s\n",yytext);
	return ASSIGN_OP;}

[+|-|*|/|%] {fprintf(yyout,"Operator:		%s\n",yytext);
		return yytext[0];}
		
([0-9]+[a-z|A-Z|_|@|#|$|%|"^"|&]+)		{fprintf(yyout,"INVALID TOKENS:	%s\n",yytext);}


. 			{fprintf(yyout,"INVALID TOKENS:	%s\n",yytext);}
									
%%


Node * define_resolver(char * id, int line, int scope)		// To resolve the define macro and put entry in symbol table
{
	if (scope == 0){
		char s[20] = "#define";
		int ptr = 0,i;
		int all_step = 0;
		char * var = (char *)malloc(33);
		char * temp = var;
		int p = 0;
		for (i=0; s[i] != '\0' && id[ptr] != '\0' && s[i] == id[ptr++]; i++){
			all_step = 1;
		}
		if (s[i] == '\0')
		{
			for (; id[ptr] != '\0' && id[ptr] == ' '; ptr++){
				all_step = 2;
			}
			for (; id[ptr] != '\0' && id[ptr] != ' '; ptr++)
			{
				all_step = 3;
				var[p] = id[ptr];
				p++;
			}
			var[p] = '\0';
			for (; id[ptr] != '\0' && id[ptr] == ' '; ptr++){
				all_step = 4;
			}
			char val[33] = {'\0'};
			p = 0;
			for (; id[ptr] != '\0'; ptr++)
			{
				all_step = 5;
				val[p] = id[ptr];
			}
		}
		if (all_step != 5)
		{
			printf("\nERROR: DEFINE NOT DECLARED PROPERLY\n");
		}
		else
		{
			temp = var;
			insert(temp,0,"macros",line,0);
			return lookup(temp,scope);
		}
	}
	else
	{
		printf("ERROR: Declared in local scope\n");
		printf("Stopping...\n");
		exit(0);
	}
}




int count_new_line(char * id)				//To count new lines in case of multi-line comments
{
	int count = 0;
	for (int i=0; id[i] != '\0'; i++)
	{
		if (id[i] == '\n')
		{
			count++;
		}
	}
	return count;
}



Node* init_Node(char * key, int value, char * type, int Line_Number, int val) 			//To construct a Node for symbol table entry
{
	Node * this = (Node *)malloc(sizeof(Node));
	this->identifier = strdup(key); 
	this->scope = value; 
	this->value = val; 
	this->type = strdup(type); 
	this->Line_Number = Line_Number; 
	this->next_Node = NULL; 
	return this;
} 

void init_symbol() 					//To initialise the symbol table with NULL values
{ 
	for (int i = 0; i < SIZE; i++) 
		s_table.header[i] = NULL; 
}


unsigned int hash(char * id) 				//To calculate the hash value to find suitable mapping for the symbol table entry
{ 
	unsigned int asciiSum = 0; 
	for (int i = 0; id[i] != '\0'; i++) { 
		asciiSum = asciiSum + id[i]; 
	} 
	return (asciiSum % SIZE); 
}


int insert(char * id, int scope, char * Type, int Line_Number, int val) 		//Function to insert records in symbol table
{ 
	unsigned int index = hash(id); 
	Node* p = init_Node(id, scope, Type, Line_Number,val); 
	if (s_table.header[index] == NULL) { 
		s_table.header[index] = p; 
		return 1; 
	}
	else { 
		Node* start = s_table.header[index]; 
		while (start->next_Node != NULL) 
			start = start->next_Node;
		start->next_Node = p; 
		return 1; 
	} 
	return 0; 
} 


void insert_into_symbol_table(char * id, int scope, char * Type, int Line_Number, int val)	//To insert value if not found in symbol table
{
	Node * found = lookup(id,scope);
	if (found == NULL)
	{
		insert(id,scope,Type,Line_Number,val);
	}
}


int modify(char* id, int s, char* t, int l, int val) 		//To modify a symbol table entry
{ 
	unsigned int index = hash(id); 
	Node* start = s_table.header[index]; 
	if (start == NULL) 
		return -1; 

	while (start != NULL) { 
		if (strcmp(start->identifier,id) == 0 && start->scope == s) { 
			start->type = strdup(t); 
			start->Line_Number = l; 
			start->value = val; 
			return 1; 
		} 
		start = start->next_Node; 
	} 

	return 0; // id not found 
}


Node * lookup(char * id, int scope) 			//To search for a record in symbol table with given name and scope
{ 
	unsigned int index = hash(id); 
	Node* start = s_table.header[index]; 

	if (start == NULL) 
		return NULL; 

	while (start != NULL) { 

		if (strcmp(start->identifier,id) == 0 && start->scope == scope) {
			return start; 
		} 

		start = start->next_Node; 
	} 

	return NULL; // not found 
}

int remove_symbol(char * id) 				//To remove an entry from symbol table
{ 
	unsigned int index = hash(id); 
	Node* temp = s_table.header[index]; 
	Node* par = s_table.header[index]; 

	// no identifier is present at that index 
	if (temp == NULL) { 
		return 0; 
	} 
	// only one identifier is present 
	if (strcmp(temp->identifier,id) == 0 && temp->next_Node == NULL) { 
		temp->next_Node = NULL; 
		return 0; 
	} 

	while (strcmp(temp->identifier,id) != 0 && temp->next_Node != NULL) { 
		par = temp; 
		temp = temp->next_Node; 
	} 
	if (strcmp(temp->identifier,id) == 0 && temp->next_Node != NULL) { 
		par->next_Node = temp->next_Node; 
		temp->next_Node = NULL; 
		return 1; 
	} 

	// delete at the end 
	else { 
		par->next_Node = NULL; 
		temp->next_Node = NULL; 
		return 1; 
	} 
	return 0; 
} 


void init_symbol_table_with_keywords()
{
	insert("int",-1,"keyword",-1,0);
	insert("if",-1,"keyword",-1,0);
	insert("else",-1,"keyword",-1,0);
	insert("return",-1,"keyword",-1,0);
	insert("==",-1,"operator",-1,0);
	insert("=",-1,"operator",-1,0);
	insert("+",-1,"operator",-1,0);
	insert("-",-1,"operator",-1,0);
	insert("*",-1,"operator",-1,0);
	insert("/",-1,"operator",-1,0);
}


int yywrap()
{
	return 1;
}



