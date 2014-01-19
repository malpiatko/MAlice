%{
#include "malice.h"
#include "yaccMalice.tab.h"
#include <stdio.h>
extern YYLTYPE yylloc;
void yyerror(char *);
#define YY_USER_INIT {yylloc.first_line = 1; yylloc.first_column = 0;}
void nextColumn(size_t len);
%}

%%

	/* Arrays */
had		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (SIZE);}
\'s 	 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (OPENARR);}
piece	 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (CLOSEARR);}

	/* Initialization Declaration */
"was a" 	 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (DECLARE);}
too					;	
became	 	 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (INITIALIZE);}

	/* Control Flow */
perhaps|either				{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (IF);}
so 		 			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (THEN);}
"or maybe" 				{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (ELSEIF);}
or 	 				{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (ELSE);}
"because Alice was unsure which"	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (ENDIF);}
eventually 				{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (WHILE);}
because					{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (BEGINWHILE);}
"enough times" 				{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (ENDWHILE);}

	/* Functions and procedures */
"contained a" 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (RETURNTYPE);}
"Alice found" 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (RETURN);}
of 		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (OF);}
"The room" 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (FUNCTION);}
"The looking-glass"   	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (PROCEDURE);}
opened	 	 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (OPEN);}
closed	 	 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (CLOSE);}
\) 		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (BRIGHT);}
\( 		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (BLEFT);}

	/* Input Output */
"what was" 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (INPUT);}
"?"			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (INPUTEND);}
"said Alice"|"spoke" 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (OUTPUT);}

	/* Program syntax */	
and|but|then		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return(CONCAT);}
\,			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return(COMMA);}
\. 		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (DOT);}

	/* Booleans */
"=="	 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (EQ);}
"&&" 			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (AND);}
">="			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (GE);}
"<="			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (LE);}
">"			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (G);}
"<"			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (L);}
"!"			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (NOTBOOL);}
"!="			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (NE);}
"||"		 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (OR);}

	/* Operations */
"+" 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (PLUS);}
"-"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (MINUS);}
"/"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (DIV);}
"^"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (XOR);}
"&"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (BAND);}
"|"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (BOR);}
"*"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (MULT);}
"%"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (MODULO);}
"~"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (NOT);}
"drank"		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (DECREMENT);}
"ate"	 	{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (INCREMENT);}

	/* Types and variables */
letter 			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return(LETTERTYPE);}
number 			{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return(NUMBERTYPE);}
sentence 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return(SENTENCETYPE);}
spider 	 		{ yylloc.first_column = nextToken;
					nextColumn(yyleng);
					return (POINTERTYPE);}



[0-9]+ 		{
			yylval.number = atoi(yytext);
			 
			yylloc.first_column = nextToken;
								nextColumn(yyleng);
								return (NUMBER);
			}
\'[a-zA-Z]\' 		{
			yylval.letter = yytext[1];
			 
			yylloc.first_column = nextToken;
								nextColumn(yyleng);
								return (LETTER);
			}
\"[^\"\n]*\"		{
			int lines;
			lines = newLines(yytext);
			if(lines > 0){
				yylloc.first_line+= lines;
				nextToken = 0;
			}
			yylval.sentence	= yytext;
			yylloc.first_column = nextToken;
								nextColumn(yyleng);
								return (SENTENCE);
			}

[a-zA-Z][a-zA-Z0-9_]*	{
			yylval.variable = yytext;
			yylloc.first_column = nextToken;
								nextColumn(yyleng);
								return (VARIABLE);
			}

[ \t]+		{yylloc.first_column = nextToken;
			nextColumn(yyleng);}
\n			{
				yylloc.first_line++;
				nextToken = 0;
			}
.			{ yyerror("syntax error, token not known to the MAlice language"); exit(1); }

%%
int yywrap(void) {
	return 1;
}

int newLines(char *s){
	int output = 0;
	int i = 0;
	for(; s[i]!= '\0'; i++){
		if(s[i] == '\n') output++;
	}
	return output;
}

void nextColumn(size_t len){
	nextToken += len;
}