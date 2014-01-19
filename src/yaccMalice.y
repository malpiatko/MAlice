%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "string.h"
#include "enums.h"
#include "malice.h"
#include "symbol_table.h"


/* prototypes */
int yylex(void);
extern FILE* yyin;
int ex(nodeType *p);
int yydebug = 1;
void freeNode(nodeType *p);
void checkForHatta();
void codeGenerate(nodeType *p, char* fileName);
static char* fileName;
nodeType *number(int value);
nodeType *letter(char letter);
nodeType *opr(int line, operEnum oper, int nops, ...);
nodeType *arr(nodeType *name, nodeType *index);
nodeType *variable(int line, int column, char *var);
nodeType *sentence(char *sentence);
nodeType *function(int line, nodeType *name, nodeType *params,
nodeType* type, nodeType* body);
nodeType *parameters(nodeType* parameter);
nodeType *type(variableType t);
nodeType *declare(nodeType* variable, nodeType* type);
nodeType *concat(nodeType* left, nodeType* right);
nodeType *scope(nodeType* declarations, nodeType* executables);
nodeType* funcCall(nodeType* variable, nodeType* parameter);
nodeType* arrayinit(nodeType *name, nodeType *length, nodeType *type);
nodeType* arrayelem(nodeType* array, nodeType *element);
nodeType* pointer(nodeType* type);
nodeType* ifStat(int line, nodeType* expr, nodeType* body);
char tokenizer[] = " ,.*+-/()[]%><|!=^&?'";



void yyerror();
%}

%union {
	int number;
	char letter;
	char *sentence;
	char *variable;
	nodeType *nPtr;
	operEnum op;
}

%locations
%error-verbose

%token SIZE OPENARR CLOSEARR POINTER BLEFT BRIGHT
%token DECLARE INITIALIZE 
%token IF THEN ELSEIF ELSE ENDIF WHILE BEGINWHILE ENDWHILE
%token RETURNTYPE RETURN OF FUNCTION PROCEDURE MAIN OPEN CLOSE
%token INPUT INPUTEND OUTPUT
%token CONCAT COMMA DOT 
%token LETTERTYPE NUMBERTYPE SENTENCETYPE POINTERTYPE
%token EQ AND GE LE G L NE OR INCREMENT DECREMENT NOTBOOL
%token PLUS MINUS DIV XOR BAND BOR MULT MODULO NOT 

%token <number> NUMBER 
%token <letter> LETTER 
%token <sentence> SENTENCE
%token <variable> VARIABLE

%left OR
%left AND
%left BOR
%left XOR
%left BAND
%left EQ NE
%left GE LE G L
%left PLUS MINUS
%left MULT DIV MODULO
%right NOT NOTBOOL UMINUS

%type <nPtr> statement expr statement_list simple_statement simple_statement_list base type if_statement_list
%type <nPtr> function parameter_list declaration scope parameters procedure
%type <nPtr> declaration_list input program
%type <nPtr> expr_list exprs declarations parameter_type


%%

program: 
	declarations 	{ $$ = scope($1, NULL); functions[(int) $$->type]($$, table);
				checkForHatta(); 
				//codeGenerate($1, fileName);
				}
				
	;

function:
	FUNCTION VARIABLE parameter_list RETURNTYPE type scope 
			{ $$ = function(@1.first_line, variable(@2.first_line, @2.first_column, 
				strtok($2,tokenizer)),$3,$5,$6);}
	;

procedure:
	 PROCEDURE VARIABLE parameter_list scope
			{ $$ = function(@1.first_line, variable(@2.first_line, @2.first_column, 
				strtok($2,tokenizer)),$3,NULL,$4);}
	;

declarations:
	declarations procedure  	{ $$ = concat($1,$2); }
	| declarations declaration_list DOT
					{ $$ = concat($1,$2); }
	| declarations function 	{ $$ = concat($1,$2); }
	| declaration_list DOT		{ $$ = $1; }
	| procedure 			{ $$ = $1; }
	| function 			{ $$ = $1; }
	;

declaration:
	 VARIABLE DECLARE type		{ $$ = declare(variable(@1.first_line, @1.first_column, 
	 								strtok($1,tokenizer)), $3);}
	| VARIABLE DECLARE type	OF expr	{ $$ = concat(declare(variable(@1.first_line, @1.first_column, 
									strtok($1,tokenizer)), $3), 
									opr(@2.first_line, INITIALIZEenum, 2, variable(@1.first_line, @1.first_column, strtok($1, tokenizer)), $5)); }
	| VARIABLE SIZE expr type	{ $$ = arrayinit(variable(@1.first_line, @1.first_column,
									strtok($1, tokenizer)),$3,$4); } 
	;

declaration_list:
	declaration
	| declaration_list CONCAT declaration
					{ $$ = concat($1,$3); }
	| declaration_list COMMA declaration
					{ $$ = concat($1,$3); }
	;

scope:
	OPEN declaration_list CONCAT simple_statement_list DOT statement_list CLOSE
					{ $$ = scope($2,concat($4,$6));}
 	| OPEN declaration_list CONCAT simple_statement_list DOT CLOSE
					{ $$ = scope(concat($2,NULL),$4);}
	| OPEN declaration_list COMMA simple_statement_list DOT CLOSE
					{ $$ = scope(concat($2,NULL),$4);}
	| OPEN declarations declaration_list CONCAT simple_statement_list DOT CLOSE
					{ $$ = scope(concat($2,$3),$5);}
	| OPEN declarations declaration_list COMMA simple_statement_list DOT CLOSE
					{ $$ = scope(concat($2,$3),$5);}
	| OPEN declarations statement_list CLOSE
					{ $$ = scope($2, $3);}
	| OPEN statement_list CLOSE	{ $$ = scope(NULL,$2);}

	| OPEN declarations declaration_list CONCAT simple_statement_list DOT statement_list CLOSE
					{ $$ = scope(concat($2,$3),concat($5,$7));}
	| OPEN declarations declaration_list COMMA simple_statement_list DOT statement_list CLOSE
					{ $$ = scope(concat($2,$3),concat($5,$7));}
	| OPEN declaration_list COMMA simple_statement_list DOT statement_list CLOSE
					{ $$ = scope($2,concat($4,$6));}
	| OPEN CLOSE 	{ $$ = scope(NULL, NULL);}
	;

parameter_list:
	BLEFT BRIGHT 			{ $$ = parameters(NULL); }
	| BLEFT parameters BRIGHT 	{ $$ = parameters($2); }
	;

parameters:
	parameter_type VARIABLE 	{ $$ = declare(variable(@2.first_line, @2.first_column, 
									strtok($2,tokenizer)), $1); }
	| parameters COMMA parameter_type VARIABLE
		 			{ $$ = concat($1, declare(variable(@4.first_line, @4.first_column, 
		 							strtok($4,tokenizer)), $3)); }
	;

parameter_type:
	POINTERTYPE type 	{ $$ = pointer($2); }
	| type 			{ $$ = $1; }

type:	
	NUMBERTYPE	{ $$ = type(INT); }
	| LETTERTYPE 	{ $$ = type(CHAR); }
	| SENTENCETYPE	{ $$ = type(STRING); }
	;	

expr: 
	base			{ $$ = $1; } 
	| MINUS expr %prec UMINUS
				{ $$ = opr(@1.first_line, MINUSenum, 1, $2); }
	| PLUS expr %prec UMINUS
				{ $$ = opr(@1.first_line, PLUSenum, 1, $2); }
	| NOT expr %prec UMINUS	{ $$ = opr(@1.first_line, NOTenum, 1, $2); }
	| NOTBOOL expr %prec UMINUS
				{ $$ = opr(@1.first_line,NOTBOOLenum, 1, $2); }
	| BLEFT expr BRIGHT 	{ $$ = $2; }
	| expr L expr		{ $$ = opr(@2.first_line, Lenum, 2, $1, $3);  }	
	| expr G expr		{ $$ = opr(@2.first_line, Genum, 2, $1, $3); }
	| expr PLUS expr	{ $$ = opr(@2.first_line,PLUSenum, 2, $1, $3); }	
	| expr MINUS expr	{ $$ = opr(@2.first_line,MINUSenum, 2, $1, $3); }
	| expr OR expr		{ $$ = opr(@2.first_line, ORenum, 2, $1, $3); }
	| expr AND expr		{ $$ = opr(@2.first_line, ANDenum, 2, $1, $3); }
	| expr MODULO expr	{ $$ = opr(@2.first_line, MODULOenum, 2, $1, $3); }
	| expr XOR expr		{ $$ = opr(@2.first_line, XORenum, 2, $1, $3); }
	| expr BAND expr	{ $$ = opr(@2.first_line, BANDenum, 2, $1, $3); }
	| expr BOR expr		{ $$ = opr(@2.first_line, BORenum, 2, $1, $3); }
	| expr GE expr		{ $$ = opr(@2.first_line, GEenum, 2, $1, $3); }
	| expr LE expr		{ $$ = opr(@2.first_line, LEenum, 2, $1, $3); }
	| expr EQ expr 		{ $$ = opr(@2.first_line, EQenum, 2, $1, $3); }
	| expr NE expr		{ $$ = opr(@2.first_line, NEenum, 2, $1, $3); }
	| expr MULT expr	{ $$ = opr(@2.first_line, MULTenum, 2, $1, $3); }
	| expr DIV expr		{ $$ = opr(@2.first_line, DIVenum, 2, $1, $3); }
	;

expr_list:
	BLEFT BRIGHT			{ $$ = NULL;}
	| BLEFT exprs BRIGHT		{ $$ = $2; }
	;

exprs:
	expr
	| exprs COMMA expr		{ $$ = concat($1, $3); }
	;

statement_list:
	statement 			{ $$ = $1; } 
	| statement_list statement	{ $$ = concat($1, $2); }
	;

if_statement_list:
					{ $$ = NULL; }
	| ELSE statement_list
					{ $$ = $2; }
	| ELSEIF BLEFT expr BRIGHT THEN statement_list if_statement_list
					{ $$ = concat(ifStat(@1.first_line, $3, $6),$7); }
	| ELSEIF BLEFT expr BRIGHT THEN simple_statement_list COMMA if_statement_list
					{ $$ = concat(ifStat(@1.first_line, $3, $6),$8); }
	;	


statement:
	scope			 	{ $$ = $1; }
	| IF BLEFT expr BRIGHT THEN statement_list if_statement_list ENDIF
					{ $$ = concat(ifStat(@1.first_line, $3, $6),$7); }
	| IF BLEFT expr BRIGHT THEN simple_statement_list COMMA if_statement_list ENDIF
					{ $$ = concat(ifStat(@1.first_line, $3, $6),$8); }
	| WHILE BLEFT expr BRIGHT BEGINWHILE statement_list ENDWHILE 
					{ $$ = opr(@1.first_line, WHILEenum, 2, $3, $6); }
	| RETURN expr DOT		{ $$ = opr(@1.first_line,RETURNenum, 1, $2); }
	| input				{ $$ = $1; } 
	| simple_statement_list COMMA input	{ $$ = concat($1, $3); }
	| simple_statement_list DOT		{ $$ = $1; }
	| DOT 				{ $$ = NULL; }
	;

input:
	INPUT VARIABLE INPUTEND		{ $$ = opr(@1.first_line,INPUTenum, 1,
									variable(@2.first_line, @2.first_column, strtok($2,tokenizer))); }
	| INPUT VARIABLE OPENARR expr CLOSEARR INPUTEND
					{ $$ = opr(@1.first_line, INPUTenum, 1, 
									arr(variable(@2.first_line, @2.first_column, strtok($2,tokenizer)), $4));}
	;

simple_statement:
	expr INCREMENT			{ $$ = opr(@2.first_line,INCREMENTenum, 1, $1); }
	| expr DECREMENT		{ $$ = opr(@2.first_line,DECREMENTenum, 1, $1); }
	| expr OUTPUT 			{ $$ = opr(@2.first_line,OUTPUTenum, 1, $1); }
	| VARIABLE OPENARR expr CLOSEARR INITIALIZE expr
					{ $$ = arrayelem(arr(
								variable(@1.first_line, @1.first_column, strtok($1, tokenizer)), $3),$6); }
	| VARIABLE INITIALIZE expr	{ $$ = opr(@2.first_line, INITIALIZEenum, 2,
						variable(@1.first_line, @1.first_column, strtok($1,tokenizer)), $3); }
	| VARIABLE expr_list		{ $$ = funcCall(
								variable(@1.first_line, @1.first_column, strtok($1, tokenizer)), $2); }
	;

simple_statement_list:
	simple_statement_list COMMA simple_statement { $$ = concat($1,$3); }
	| simple_statement_list CONCAT simple_statement { $$ = concat($1,$3); }
	| simple_statement {$$ = $1;}
	;

base:
	VARIABLE OPENARR expr CLOSEARR 	{ $$ = 
								arr(variable(@1.first_line, @1.first_column, strtok($1, tokenizer)), $3); }
	| VARIABLE expr_list		{ $$ = 
								funcCall(variable(@1.first_line, @1.first_column, strtok($1, tokenizer)), $2); }
	| NUMBER			{ $$ = number($1); }
	| LETTER			{ $$ = letter($1); }
	| VARIABLE 			{ $$ = variable(@1.first_line, @1.first_column, strtok($1,tokenizer)); }
	| SENTENCE 			{ $$ = sentence(strtok($1,"\"")); }				
	;
%%

#define SIZE_NODETYPE ((char *) &p->con - (char *) p)

nodeType* parameters(nodeType* parameter){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(paramsNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeParams;
	p->params.parameter = parameter;
	p->params.num = 0;
	return p;
}

nodeType* funcCall(nodeType* variable, nodeType* parameter){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(funcCallNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeFuncCall;
	p->funcCall.parameter = parameter;
	p->funcCall.variable = variable;
	p->funcCall.num = 0;
	return p;
}

nodeType* ifStat(int line, nodeType* expr, nodeType* body){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(ifNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->line = line;
	p->type = typeIf;
	p->ifStat.expr = expr;
	p->ifStat.body = body;
	return p;
}

nodeType *scope(nodeType* declarations, nodeType* executables){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(scopeNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeScope;
	p->scope.declarations = declarations;
	p->scope.executables = executables;
	return p;
}

nodeType* declare(nodeType* variable, nodeType* type){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(declareNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->dec.type = type;
	p->dec.variable = variable;
	p->type =typeDeclare;
	return p;
}

nodeType *number(int value) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(conNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeCon;
	p->con.c = value;

	return p;
}

nodeType *type(variableType t) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(typeNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeType;
	p->typ.t = t;
	return p;
}

nodeType *letter(char letter) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(letterNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeChar;
	p->letter.l = letter;

	return p;
}

nodeType *variable(int line, int column, char *var) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(varNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->line = line;
	p->column = column;
	p->type = typeVar;
	p->var.v = malloc(40*sizeof(char));
	strncpy(p->var.v, var, 40);
	return p;
}

nodeType *opr(int line, operEnum oper, int nops, ...){
	va_list ap;
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(oprNodeType) + (nops - 1) * sizeof(nodeType*); 

	if((p = malloc(nodeSize)) == NULL) {
			printf("ERROR: out of memory");
	}

	p->type = typeOpr;
	p->line = line;
	p->opr.oper = oper;
	p->opr.nops = nops;
	p->opr.op = malloc(nops * sizeof(struct nodeTypeTag *));
	if(p->opr.op == NULL) {
		printf("ERROR: out of memory");
	}
	va_start(ap, nops);
	int i;
	for(i = 0; i < nops; i++) {
		p->opr.op[i] = va_arg(ap, nodeType *);
	}
	va_end(ap);
	return p;
}

nodeType *arr(nodeType *name, nodeType *index){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(arrNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeArr;
	p->arr.index = index;
	p->arr.name = name;

	return p;
}


nodeType *sentence(char *sentence) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(sentenceNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeSentence;
	p->sentence.s = sentence;
	return p;
}

nodeType *function(int line, nodeType* name, nodeType *params,
nodeType* type, nodeType* body) {
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(functionNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->line = line;
	p->type = typeFunction;
	p->function.parameters = params;
	p->function.returntype = type;
	p->function.name = name; 
	p->function.body = body;
	return p;
}


nodeType* arrayinit(nodeType *name, nodeType *length, nodeType *type){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(arrayinitNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeArrayInit;
	p->arrayini.type = type;
	p->arrayini.name = name;
	p->arrayini.length = length;
	return p;
}

nodeType* arrayelem(nodeType *array, nodeType *element){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(arrayelemNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeArrayElem;
	p->arrayelem.array = array;
	p->arrayelem.elem = element;
	return p;
}


nodeType* pointer(nodeType* type){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(pointerNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typePointer;
	p->pointer.type = type->typ.t;
	return p;
}



nodeType* concat(nodeType* left, nodeType* right){
	nodeType *p;
	size_t nodeSize = SIZE_NODETYPE + sizeof(concatNodeType);
	if((p = malloc(nodeSize)) == NULL) {
		printf("ERROR: out of memory");
	}
	p->type = typeConcat;
	p->concat.left = left;
	p->concat.right = right;
	return p;
}



void freeNode(nodeType *p) {
	int i;
	if (!p) return;
	if (p->type == typeOpr) {
		for(i=0; i<p->opr.nops; i++) {
			freeNode(p->opr.op[i]);
		}
		free (p);
	}
}

void yyerror(char *s) {
	printf("ERROR(Line %d,Column %d): %s\n", yylloc.first_line, yylloc.first_column, s);
	exit(1);
}

void checkForHatta() {
	char* x = "hatta";
	if(lookUp(table, x) == NULL) {
		printf("Symbol Table error: Unable to find a procedure 'hatta'");
		printf(" which is the entry point to the program.\n");
		exit(1);
	}

}

const char *get_filename_ext(const char *filename) {
    const char *dot = strrchr(filename, '.');
    if(!dot || dot == filename) return "";
    return dot + 1;
}

int main(int argc, char** argv) {
	if(argc == 2) {
		if (strcmp(get_filename_ext(argv[1]),"alice") == 0) {
			yyin = fopen(argv[1], "r");
			if(!yyin) 
			{
				fprintf(stderr, "can't read file %s\n", argv[1]);
				return 1;
			}
		} else {
			printf("Error, expected extension: alice\n");
			return 0;
		}
	}
	table = st_create();
	fileName = strtok(argv[1], " .");
	initializeOperations(functions);
	yyparse();
	return 0;
}

