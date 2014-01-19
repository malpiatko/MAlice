LLVM_MODULES = core jit native
LDFLAGS = `llvm-config-3.0 --ldflags`
LIBS = `llvm-config-3.0 --libs $(LLVM_MODULES)`

malice: yaccMalice.tab.o lex.yy.o symbol_table.o operations.o
	g++ yaccMalice.tab.o lex.yy.o symbol_table.o operations.o -o compile 

lex.yy.o: lex.yy.c
	gcc lex.yy.c -c

lex.yy.c: lexMalice.l
	flex lexMalice.l

yaccMalice.tab.o: yaccMalice.tab.c
	gcc yaccMalice.tab.c -c

yaccMalice.tab.c: yaccMalice.y
	bison -d yaccMalice.y

symbol_table.o: symbol_table.c symbol_table.h
	gcc symbol_table.c symbol_table.h -c
 
operations.o: operations.c 
	gcc operations.c -c

clean:
	rm -f *.o lex.yy.c yaccMalice.output
	rm -f yaccMalice.tab.c yaccMalice.tab.h
	rm -f *.h.gch
	clear
