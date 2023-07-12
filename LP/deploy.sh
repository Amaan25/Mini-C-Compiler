#!/bin/bash
yacc -d parser.y
lex lexer.l
gcc lex.yy.c y.tab.c -w
./a.out
