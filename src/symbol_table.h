#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include "malice.h"
#include "stdbool.h"
#include "enums.h"
/*variable,function, operator
variable - letter/char/sentence, value
function - returnType, InputNumber, input types
operator - type*/
/*dont really know about operands, sentences, arrays*/



typedef struct st_elem st_elem;
typedef struct functionElem functionElem;
typedef struct variableElem variableElem;
typedef struct arrayElem arrayElem;
typedef struct sentenceElem sentenceElem;
typedef struct elem elem; 
typedef struct sym_table sym_table; 

variableType (*functions[enumNumber])(nodeType* x, sym_table* table); 

sym_table* table;

struct functionElem {
	int arity;
	variableType returnType;
	variableType* input;
};

struct variableElem {
	variableType type;
};

struct arrayElem {
	int length;
	variableType type;
};

struct sentenceElem {
	int length;
	char* sentence;
};

struct elem {
	int line;
	int column;
	char *name;
	nodeEnum type;
	int reg;
	union st_t {
		variableElem var;
		arrayElem array;
		functionElem fun;
		sentenceElem sent;
	} st;
};

struct st_elem {
	st_elem *next;
	elem* node;
};

struct sym_table {
	st_elem *first;
};

void add_sentence(int line, int column, sym_table *table, char* sentence, int length);
st_elem* add_function(int line, int column, sym_table *table, char* name);
void update_function(st_elem* func, variableType returnType, int arity,	variableType* input);
void add_variable(int line, int column, sym_table *table, char* name, variableType type);
void add_array(int line, int column, sym_table *table, char* name, variableType type);
void add(int line, int column, sym_table *table, char* name);
int setReg(sym_table *table, char* name, int reg);

elem* lookUp(sym_table *table, char* name);
st_elem *beginScope(sym_table *table);
void endScope(sym_table *table, st_elem* until);

st_elem* freePart(st_elem* node, st_elem* until);
void st_free(sym_table *table);
sym_table *st_create(void);
#endif
