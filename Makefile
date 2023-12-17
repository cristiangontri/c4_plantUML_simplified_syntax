OUT = out
LEXER = lexer
PARSER = parser
PRUEBA = ./Test/AllCorrectTest.txt
PRUEBA1 = ./Test/MissingSemiColonTest.txt
PRUEBA2 = ./Test/RepeatedID.txt
PRUEBA3 = ./Test/BoundaryContainsSprite.txt
PRUEBA4 = ./Test/DeclarationBadFormed.txt

all: compile run

compile:
	flex $(LEXER).l
	bison -o $(PARSER).tab.c $(PARSER).y -yd 
	gcc -o $(OUT) lex.yy.c $(PARSER).tab.c -ll -ly
run:
	$(info **************  Analizando Archivos de Prueba  *************)
	./$(OUT) < $(PRUEBA)
	./$(OUT) < $(PRUEBA1)
	./$(OUT) < $(PRUEBA2)
	./$(OUT) < $(PRUEBA3)
	./$(OUT) < $(PRUEBA4)
clean:
	rm $(OUT) lex.yy.c $(PARSER).tab.c $(PARSER).tab.h C4_Result.pu C4_Result_1.pu C4_Result_2.pu C4_Result_3.pu C4_Result_4.pu