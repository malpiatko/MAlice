#ifndef ENUMS_H
#define ENUMS_H
#define typeNumber (POINTERARRAY + 1)

typedef enum {CHAR, INT, STRING, BOOL, VOID, ERROR, POINTERARRAY} variableType;
typedef enum {PLUSenum, MINUSenum, MULTenum, DIVenum, MODULOenum,
				XORenum, BANDenum, BORenum, GEenum, LEenum,
				NEenum, EQenum, Genum, Lenum, ORenum, ANDenum, NOTenum,
				INITIALIZEenum, INCREMENTenum, DECREMENTenum, RETURNenum,
				OUTPUTenum, WHILEenum, INPUTenum, NOTBOOLenum } operEnum;

#endif
