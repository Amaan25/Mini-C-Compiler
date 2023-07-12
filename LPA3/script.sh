#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}--> Starting${NC}"

echo -e "${RED}--> Installing Dependencies (Requires Password)${NC}"
sudo apt-get install flex bison

bison -d -y parser.y
echo -e "${RED}--> Bison Compilation Finished${NC}"

flex lexer.l
echo -e "${RED}-->Flex Compilation Finished${NC}"

gcc y.tab.c lex.yy.c -o main
echo -e "${RED}--> Executable Ready${NC}"

echo -e "${BLUE}--> Enter Input${NC}"
read input_text

mkdir -p test
echo "${input_text}" > ./test/input_test.txt
echo -e "${RED}--> Output${NC}"
./main <./test/input_test.txt> ./test/output_test.txt
cat ./test/output_test.txt

echo -e "${GREEN} \n---> NOTE: Both input and output are available within the Test directory <---${NC}"