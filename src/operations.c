#include "enums.h"
#include "malice.h"
#include "symbol_table.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


variableType declareFun(nodeType* x, sym_table* table);
variableType oprFun(nodeType* x, sym_table* table);
variableType numFun(nodeType* x, sym_table* table);
variableType charFun(nodeType* x, sym_table* table);
variableType varFun(nodeType* x, sym_table* table);
variableType concatFun(nodeType* x, sym_table* table);
variableType sentenceFun(nodeType* x, sym_table* table);
variableType paramsFun(nodeType* x, sym_table* table);
variableType scopeFun(nodeType* x, sym_table* table);
variableType funcCallFun(nodeType* x, sym_table* table);
variableType arrayinitFun(nodeType* x, sym_table* table);
variableType functionFun(nodeType* x, sym_table* table);
variableType arrayelemFun(nodeType* x, sym_table* table);
variableType arrayFun(nodeType* x, sym_table* table);
variableType ifFun(nodeType* x, sym_table* table);
bool checkForDoubles(st_elem* current, st_elem* x, bool b);
int checkNodesExpr(int arity, nodeType* x, elem* func, int i, sym_table* table);
int parseThroughParams(nodeType* p, int i, sym_table* table);



const char* variables[] = {"'letter'", "'number'", "'sentence'", "'boolean'", "'void'", "bla"};
const char* binaryOp[] =  {"'+'", "'-'", "'*'", "'\\'", "'%'", "'^'", "'&'", "'|'", "'>='", "'<='",
							 "'!='", "'=='", "'>'", "'<'", "'||'", "'&&'", "'~'"};


void initializeOperations(){
	functions[(int) typeDeclare] = declareFun;
	functions[(int) typeOpr] = oprFun;
	functions[(int) typeCon] = numFun;
	functions[(int) typeChar] = charFun;
	functions[(int) typeVar] = varFun;
	functions[(int) typeConcat] = concatFun;
	functions[(int) typeSentence] = sentenceFun;
	functions[(int) typeParams] = paramsFun;
	functions[(int) typeScope] = scopeFun;
	functions[(int) typeFuncCall] = funcCallFun;
	functions[(int) typeArrayInit] = arrayinitFun;
	functions[(int) typeArr] = arrayFun;
	functions[(int) typeFunction] = functionFun;
	functions[(int) typeArrayElem] = arrayelemFun;
	functions[(int) typeIf] = ifFun;
}




variableType declareFun(nodeType* x, sym_table* table){
	nodeType* variable = x->dec.variable;
	nodeType* type = x->dec.type;
	if(type->type == typePointer) {
		add_array(variable->line, variable->column,
				table, strtok(variable->var.v,",().-*/+%><!|=^&[]' "),type->pointer.type);
	} else {
		add_variable(variable->line, variable->column,table, 
				strtok(variable->var.v,",().-*/+%><!|=^&[]' "), type->typ.t);
	}
	return VOID;
}

variableType funcCallFun(nodeType* x, sym_table* table){
	nodeType* p = x->funcCall.parameter;
	char* name = x->funcCall.variable->var.v;
	elem* func = lookUp(table, name);
	int arity = func->st.fun.arity;
	if(func == NULL) {
		printf("No previous declaration of function %s\n", name);
		return VOID;
	}
	if(p == NULL && func->st.fun.arity != 0){
		printf("No arguments given to function %s which takes arguments.\n", name);
		return VOID;
	}
	int numArgs = checkNodesExpr(arity, p, func, 0, table);
	if(numArgs != arity) {
		printf("Error in Expression Checker: ");
		printf("The number of actual parameters in the call to '%s'", name);
		printf(" on line %d is %d, which does not match", x->funcCall.variable->line, numArgs);
		printf(" the number of expected formal parameters of %d.\n", arity);

	}
	return func->st.fun.returnType;
}

variableType ifFun(nodeType* x, sym_table* table){
	variableType exprType;
	exprType = functions[(int) x->ifStat.expr->type](x->ifStat.expr, table);
	if(exprType != BOOL){
		printf("\nThe expression is of type: %d\n", exprType);
		printf("Error in Expression Checker: ");
		printf("If statement conditional on line %d does not evaluate to a Boolean.\n",
			x->line);
	}
	if (x->ifStat.body == NULL) { 
		return VOID;
	} else {
		return functions[(int) x->ifStat.body->type](x->ifStat.body, table);
	}
}

int checkNodesExpr(int arity, nodeType* x, elem* func, int i, sym_table* table){
	if(x == NULL) {
		if(func->st.fun.arity != 0) {
			printf("Arguments given to void function\n");
		}
		return i;
	}
	if(x->type == typeConcat){
		i = checkNodesExpr(arity, x->concat.left, func, i, table);
		i = checkNodesExpr(arity, x->concat.right, func, i, table);
	} else{
		if(i < arity){
			variableType t = functions[(int) x->type](x, table);
			variableType arrType = t;
			if(x->type == typeVar){
				elem* info = lookUp(table, x->var.v);
				if(info->type == typeArr){
					t = POINTERARRAY;
				}
				if(info->type == typeFunction){
					printf("here something is wrong");
				}
			}
			if(t != func->st.fun.input[i]) {
				printf("Error in Expression Checker: ");
				if(t == POINTERARRAY && func->st.fun.input[i] != POINTERARRAY){
					printf("Actual parameter #%d in call to '%s'", i+1, func->name);
					printf(" is passed by reference" );
					printf(" but the corresponding formal parameter is expecting a value.\n");

				} else if(t != POINTERARRAY && func->st.fun.input[i] == POINTERARRAY){
					printf("Actual parameter #%d in call to '%s'", i+1, func->name);
					printf(" is passed by value" );
					printf(" but the corresponding formal parameter is expecting a reference to an array.\n");
				}else{
					if(t == POINTERARRAY){
						t = arrType;
					} if(t != func->st.fun.input[i]){
						printf("Type of actual argument #%d", i+1);
						printf(" in call to '%s' ", func->name);
						printf("does not match the type of the corresponding formal parameter.");
						printf(" The actual argument has type %s and the formal parameter has type %s.\n",
							variables[t], variables[func->st.fun.input[i]]);
					}
				}
			}
		}
		i++;
	}
	return i;
}

variableType arrayinitFun(nodeType* x, sym_table* table){
	nodeType *variable = x->arrayini.name;
	if(functions[x->arrayini.length->type](x->arrayini.length, table) == INT) {
		add_array(variable->line, variable->column, table, variable->var.v, x->arrayini.type->typ.t);
	} else {
		printf("Error, length must be an integer\n");
	}
	return VOID;
}

variableType arrayFun(nodeType* x, sym_table* table){
	elem *array_elem = lookUp(table, x->arr.name->var.v);
	if(array_elem != NULL) {
		if (array_elem->type == typeArr) {
			if (functions[x->arr.index->type](x->arr.index, table) == INT) {
				return array_elem->st.array.type;
			} else {
				printf("Error, the index must resolve to an integer\n");
			}
		} else {
			printf("Error, trying to access offset in %s", x->arr.name->var.v);
			printf(" which is not an array\n");
			return ERROR;
		}
	}
	printf("Error, array %s is undeclared\n", x->arr.name->var.v);
	return VOID;
}



variableType arrayelemFun(nodeType* x, sym_table* table){
	variableType expectedType = arrayFun(x->arrayelem.array, table);
	if (expectedType != functions[x->arrayelem.elem->type]( x->arrayelem.elem, table)) {
		printf("Error, wrong type inside array\n");
	}
	return VOID;
}

variableType paramsFun(nodeType* x, sym_table* table){
	nodeType* p = x->params.parameter;
	if(p == NULL){
		return VOID;
	}
	x->params.num = parseThroughParams(p, 0, table);
	return VOID;
}

/*we are gonne put the types by parsing on the symbol table until we get to where the function was declared*/
int parseThroughParams(nodeType* p, int i, sym_table* table){
	if(p->type == typeConcat){
		i = parseThroughParams(p->concat.right, i, table);
		i = parseThroughParams(p->concat.left, i, table);
	} else {
		declareFun(p, table);
		i++;
	}
	return i;
}

bool checkForDoubles(st_elem* current, st_elem* x, bool b) {
	if(x != NULL && x != current) {
		st_elem* iterator = x->next;
		while(iterator != NULL && iterator != current && 
			iterator->node != NULL && x->node != NULL){
			if(!strncmp(iterator->node->name, x->node->name, 40)) {
				printf("Symbol Table error(Line %d, Column %d): ", x->node->line, x->node->column);
				printf("Symbol '%s' ", x->node->name);
				printf("declared more than once in the same scope.\n");
				printf("note: previous declaration at line %d, column %d.\n",
						iterator->node->line, iterator->node->column);
				b = true;
				break;
			}
			iterator = iterator->next;
		}
		checkForDoubles(current, x->next, b);
	}
	return b;
}

variableType scopeFun(nodeType* x, sym_table* table){
	st_elem* current = beginScope(table);
	variableType output;
	nodeType* declarations = x->scope.declarations;
	nodeType* executables = x->scope.executables;
	if(declarations != NULL){
		functions[(int) declarations->type](declarations, table);
	}
	if(checkForDoubles(current, table->first, false)) {
		return VOID;
	}
	if(executables == NULL){
		return VOID;
	}
	output = functions[(int) executables->type](executables, table);
	endScope(table, current);
	return output;
}

variableType functionFun(nodeType *x, sym_table* table) {
	nodeType* variable = x->function.name;
	char* name = variable->var.v;
	st_elem* current = add_function(variable->line, variable->column, table, name);
	paramsFun(x->function.parameters,table);
	variableType expectedType = VOID;
	if (x->function.returntype != NULL) {
		expectedType = x->function.returntype->typ.t;
	}
	int numElems = x->function.parameters->params.num;
	variableType* array = malloc(sizeof(variableType)*numElems);
	st_elem* iterate = table->first;
	int i = 0;
	while(iterate != current) {
		if(iterate->node->type == typeArr) {
			array[i] = POINTERARRAY;
		} else {
			array[i] = iterate->node->st.var.type;
		}
		//doesn't check that you're passing an array, only what's in it
		iterate = iterate->next;
		i++;
	}
	update_function(current, expectedType, numElems, array);
	variableType returnType = scopeFun(x->function.body, table);
	if(expectedType != VOID && returnType == VOID){
		printf("Warning in Function Return Checker: ");
		printf("There are paths through '%s' that do not return type.\n", name);
	}
	if(returnType != VOID && returnType != expectedType && returnType != ERROR) {
		printf("Error in Function Return Checker: ");
		printf("Expected return type %s ", variables[expectedType]);
		printf("for the function '%s', ", name);
		printf("instead get return type %s.\n", variables[returnType]);
		printf("note: only first return statement is checked.\n");
	}
	if(expectedType != VOID && !strncmp("hatta", name, 6)){
		printf("Symbol Table error(Line %d, Column %d): ", x->line, x->column);
		printf("The main subprogram 'hatta' is defined as a function. It should be a procedure.\n");
	}
	endScope(table, current);
	return VOID;
}

variableType oprFun(nodeType* x, sym_table* table){
	int line = x->line;
	operEnum oper = x->opr.oper;
	nodeType* right;
	variableType rightType;
	nodeType* left = x->opr.op[0];
	variableType leftType = functions[(int) left->type](left,table);
	if(leftType == ERROR || leftType == VOID){
		return VOID;
	}
	if(left->type == typeVar){
		elem* x = lookUp(table, left->var.v);
		if(x != NULL){
			if(x->type != typeVar){
				printf("Reference to '%s' in line %d is not an r-value.\n", left->var.v, line);
			}
		}
	}
	if(oper == WHILEenum){
		if (leftType != BOOL || leftType == ERROR) {
			printf("Error in Expression Checker: ");
			printf("Loop header conditional on line %d does not evaluate to a Boolean.\n",
				line);
		}
		return VOID;
	}
	if(x->opr.nops != 1){
		right = x->opr.op[1];
		rightType = functions[(int) right->type](right,table);
		if(rightType == ERROR || rightType == VOID){
			return VOID;
		}
		if(right->type == typeVar){
			elem* x = lookUp(table, right->var.v);
			if(x != NULL){
				if(x->type != typeVar){
					printf("Reference to '%s' in line %d is not an r-value.\n", right->var.v, line);
				}
			}
		}
		if(leftType != rightType){
			printf("Error in Expression Checker: Type clash in ");
			if(oper == INITIALIZEenum){
				printf("assignment on line %d.", line);
			} else{
				printf("binary operator %s on line %d.", binaryOp[oper], line);
			}
		 	printf(" One type is %s and the other is %s.\n",
				variables[leftType], variables[rightType],
				left->type, right->type);
		}
	}
	if(oper <= BORenum){
		if(leftType == BOOL){
			if(x->opr.nops == 1){
				printf("Error in Expression Checker: ");
				printf("Unary operator %s on line %d not applied to integer.\n", binaryOp[oper], line);
			} else{
				printf("some nice writing.\n");
			}
			return ERROR;
		} else if(x->opr.nops != 1){
			if(rightType == BOOL){
				printf("Calling integer/character operator on boolean values");
				printf(" on line %d\n", line); 
				return ERROR;
			}
		}
		return leftType;
	} else if(oper < ORenum){
			if(leftType == BOOL || leftType == STRING || rightType == STRING || 
				rightType == BOOL){
				printf("Error in Expression Checker: ");
				printf("Relational character not applied to integer or character values.\n");
			}
			return BOOL;
	} else if(oper <= ANDenum){
			if(leftType != BOOL || rightType != BOOL){
				printf("Error in Expression Checker: Logical operator ");
				printf("%s on line %d not applied to Boolean values.\n", binaryOp[oper], line);
			}
			return BOOL;
	} else if(oper == NOTenum){
			if(leftType != INT){
				printf("Error in Expression Checker: ");
				printf("Unary operator %s on line %d not applied to integer.\n", binaryOp[oper], line);
			}
			return leftType;
	}else if(oper == NOTBOOLenum){
			if(leftType != BOOL){
				printf("Error in Expression Checker: ");
				printf("Unary operator '!' on line %d not applied to boolean.\n", line);
			}
			return leftType;
	} else if(oper == RETURNenum){
			return leftType;
	} else if(oper == INCREMENTenum || oper == DECREMENTenum){
		if(left->type != typeVar){
			printf("Statement on line %d not an l-value\n", line);
		} if(leftType != INT){
			printf("Error in Expression Checker: ");
			if(oper == INCREMENTenum){
				printf("Increment ");
			} else{
				printf("Decrement ");
			}
			printf("statement in line %d not applied to integer.\n", line);
		}
	}
	return VOID;
}

variableType concatFun(nodeType* x, sym_table* table){
	variableType leftType = VOID;
	variableType rightType = VOID;
	nodeEnum left = typeVar;
	nodeEnum right = typeVar;
	if(x->concat.left != NULL) {
		left = x->concat.left->type;
		leftType = functions[(int) left](x->concat.left, table);
	}
	if(x->concat.right != NULL) {
		right = x->concat.right->type;
		rightType = functions[(int) right](x->concat.right, table);
	}
	if(left == typeIf && right == typeIf){
		if(leftType == VOID && rightType == VOID){
			return VOID;
		} else {
			return rightType;
		}
	}

	if(leftType == VOID){
		return rightType;
	} else {
		return leftType;
	}

}

variableType numFun(nodeType* x, sym_table* table){
	return INT;
}
variableType charFun(nodeType* x, sym_table* table){
	return CHAR;
}
variableType sentenceFun(nodeType* x, sym_table* table){
	return STRING;
}



variableType varFun(nodeType* x, sym_table* table){
	elem* info = lookUp(table, x->var.v);
	if(info == NULL){
		printf("Symbol Table error(Line %d, Column %d): ", x->line, x->column);
		printf("unable to find symbol for reference '%s'.\n", x->var.v);
		return ERROR;
	} 
	if(info->type == typeArr) {
		return info->st.array.type;
	}
	if(info->type == typeFunction){
		return info->st.fun.returnType;
	}
	if(info->type == typeSentence){
		return STRING;
	}
	return info->st.var.type;
}
