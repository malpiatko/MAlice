#include "symbol_table.h"
#include "malice.h"
#include <stdlib.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void add(int line, int column, sym_table *table, char* name) {
	st_elem *newElem =(st_elem *) malloc(sizeof(st_elem));
	newElem->next = table->first;
	newElem->node = (elem *) malloc(sizeof(elem));
	newElem->node->line = line;
	newElem->node->column = column;
	newElem->node->reg = -1;
	newElem->node->name = name;
	table->first = newElem;
}	

st_elem* add_function(int line, int column, sym_table *table, char* name){
	add(line, column, table, name);
	elem* x = table->first->node;
	x->type = typeFunction;
	return table->first;
}

void update_function(st_elem* func, variableType returnType, int arity,
variableType* input) {
	elem* x = func->node;
	x->st.fun.arity = arity;
	x->st.fun.returnType = returnType;
	x->st.fun.input = input;
}

void add_variable(int line, int column, sym_table *table, char* name, variableType type){
	add(line, column, table, name);
	elem* x = table->first->node;
	x->type = typeVar;
	x->st.var.type = type;
}

void add_array(int line, int column, sym_table *table, char* name, variableType type){
	add(line, column, table, name);
	elem* x = table->first->node;
	x->type = typeArr;
	x->st.array.type = type;
}

void add_sentence(int line, int column, sym_table *table, char* sentence, int length) {
	add(line, column, table, sentence);
	
}

sym_table* st_create(void) {
	sym_table *table = (sym_table *) malloc(sizeof(sym_table));
	table->first = NULL;
	return table;
}

elem* lookUp(sym_table *table, char* name){
	st_elem* x = table->first;
	while(x != NULL){
		if(x->node != NULL && !strncmp(x->node->name, name, 40)){
			return x->node;
		}
		x = x->next;
	}
	return NULL;
}

st_elem *beginScope(sym_table *table){
	return table->first;
}

//Set the reg value of the item with name name with reg in the symbol
//table. If the elem belongs and the allocation is succesful, return 1
//other wise return 0.
int setReg(sym_table *table, char* name, int reg) {
		elem *newElem = lookUp(table,name);
		if(newElem == NULL) {
				return 0;
		} else {
				newElem->reg = reg;
				return 1;
		}
}

void endScope(sym_table *table, st_elem* until){
	table->first = freePart(table->first, until);
}	

st_elem *freePart(st_elem* elemToDel, st_elem* until) {
	if(elemToDel != NULL && elemToDel != until) {
		freePart(elemToDel->next, until);
		free(elemToDel->node);
		free(elemToDel);
	}
	return until;
}

void st_free(sym_table *table) {
	freePart(table->first, NULL);
	free(table);
}
