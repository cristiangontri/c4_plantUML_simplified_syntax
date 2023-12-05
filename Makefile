OUT = out
LEXER = lexer
PARSER = parser
PRUEBA = ./Test/test2.txt

all: compile run

compile:
	flex $(LEXER).l
	bison -o $(PARSER).tab.c $(PARSER).y -yd
	gcc -o $(OUT) lex.yy.c $(PARSER).tab.c -ll -ly
run:
	$(info **************  Analizando Ficheiros  *************)
	./$(OUT) < $(PRUEBA)
clean:
	rm $(OUT) lex.yy.c $(PARSER).tab.c $(PARSER).tab.h