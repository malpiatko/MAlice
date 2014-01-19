#ifndef MALICE_H

#define MALICE_H

#include "enums.h"

#define enumNumber (typeFuncCall + 1)

int nextToken;

typedef enum { typeCon, typeChar, typeOpr, typeArr, 
	typeType, typePointer, 
	typeFunction, typeIf,
	typeParams, typeDeclare, typeArrayInit, typeArrayElem,
	typeConcat, typeSentence, typeVar, typeScope,
	typeFuncCall
} nodeEnum;

typedef struct {
		int c;
} conNodeType;

typedef struct {
		struct nodeTypeTag* declarations;
		struct nodeTypeTag* executables;
} scopeNodeType;

typedef struct {
		struct nodeTypeTag* expr;
		struct nodeTypeTag* body;
} ifNodeType;


typedef struct {
		int num;
		struct nodeTypeTag* parameter;
} paramsNodeType;

typedef struct {
		struct nodeTypeTag* variable;
		int num;
		struct nodeTypeTag* parameter;
} funcCallNodeType;

typedef struct {
		struct nodeTypeTag* type;
		struct nodeTypeTag* name;
		struct nodeTypeTag* length;
} arrayinitNodeType;

typedef struct {
		int type;
} pointerNodeType;

typedef struct {
		struct nodeTypeTag* type;
		struct nodeTypeTag* variable;
} declareNodeType;

typedef struct {
		variableType t;
} typeNodeType;

typedef struct {
		struct nodeTypeTag* name;
		struct nodeTypeTag* index;
} arrNodeType;

typedef struct {
		char l;
} letterNodeType;

typedef struct {
		char *s;
} sentenceNodeType;

typedef struct {
		char *v;
} varNodeType;

typedef struct {
		operEnum oper;
		int nops;
		struct nodeTypeTag **op;
} oprNodeType;

typedef struct {
		struct nodeTypeTag* left;
		struct nodeTypeTag* right;
} concatNodeType;

typedef struct {
		struct nodeTypeTag* returntype;
		struct nodeTypeTag* parameters;
		struct nodeTypeTag* body;
		struct nodeTypeTag* name;
} functionNodeType;

typedef struct {
		struct nodeTypeTag* array;
		struct nodeTypeTag* elem;
} arrayelemNodeType;


typedef struct nodeTypeTag {
	nodeEnum type;
	int line;
	int column;
	union {
		conNodeType con;
		letterNodeType letter;
		varNodeType var;
		oprNodeType opr;
		arrNodeType arr;
		typeNodeType typ;
		sentenceNodeType sentence;
		functionNodeType function;
		paramsNodeType params;
		funcCallNodeType funcCall;
		declareNodeType dec;
		concatNodeType concat;
		arrayinitNodeType arrayini;
		arrayelemNodeType arrayelem;
		scopeNodeType scope;
		pointerNodeType pointer;
		ifNodeType ifStat;
	};
} nodeType;

#endif
