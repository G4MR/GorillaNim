/* Generated by Nim Compiler v0.10.3 */
/*   (c) 2015 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Windows, i386, gcc */
/* Command for C compiler:
   gcc.exe -c  -w  -ID:\Nim\lib -o d:\documents\projects\github\gorilla\nimcache\gc_types.o d:\documents\projects\github\gorilla\nimcache\gc_types.c */
#define NIM_INTBITS 32
#include "nimbase.h"
static N_INLINE(void, nimFrame)(TFrame* s);
N_NOINLINE(void, stackoverflow_19601)(void);
static N_INLINE(void, popFrame)(void);
extern TFrame* frameptr_16842;

static N_INLINE(void, nimFrame)(TFrame* s) {
	NI LOC1;
	LOC1 = 0;
	{
		if (!(frameptr_16842 == NIM_NIL)) goto LA4;
		LOC1 = ((NI) 0);
	}
	goto LA2;
	LA4: ;
	{
		LOC1 = ((NI) ((NI16)((*frameptr_16842).calldepth + ((NI16) 1))));
	}
	LA2: ;
	(*s).calldepth = ((NI16) (LOC1));
	(*s).prev = frameptr_16842;
	frameptr_16842 = s;
	{
		if (!((*s).calldepth == ((NI16) 2000))) goto LA9;
		stackoverflow_19601();
	}
	LA9: ;
}

static N_INLINE(void, popFrame)(void) {
	frameptr_16842 = (*frameptr_16842).prev;
}
NIM_EXTERNC N_NOINLINE(void, HEX00_gc_typesInit)(void) {
	nimfr("gc_types", "gc_types.nim")
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, HEX00_gc_typesDatInit)(void) {
}

