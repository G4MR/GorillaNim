/* Generated by Nim Compiler v0.10.3 */
/*   (c) 2015 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Windows, i386, gcc */
/* Command for C compiler:
   gcc.exe -c  -w  -ID:\Nim\lib -o d:\documents\projects\github\gorilla\nimcache\gc_common.o d:\documents\projects\github\gorilla\nimcache\gc_common.c */
#define NIM_INTBITS 32
#include "nimbase.h"

#include <string.h>
typedef struct gcsystemops93005 gcsystemops93005;
typedef N_CDECL_PTR(void*, TY93006) (NU32 insize);
typedef N_CDECL_PTR(void*, TY93010) (void* inptr, NU32 insize);
typedef N_CDECL_PTR(void, TY93015) (void* inptr);
struct  gcsystemops93005  {
TY93006 Allocfunc;
TY93010 Reallocfunc;
TY93015 Freefunc;
};
static N_INLINE(void, nimFrame)(TFrame* s);
N_NOINLINE(void, stackoverflow_19601)(void);
static N_INLINE(void, popFrame)(void);
gcsystemops93005 gcxops_93022;
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
NIM_EXTERNC N_NOINLINE(void, HEX00_gc_commonInit)(void) {
	gcsystemops93005 LOC1;
	nimfr("gc_common", "gc_common.nim")
	nimln(50, "gc_common.nim");
	memset((void*)(&LOC1), 0, sizeof(LOC1));
	gcxops_93022 = LOC1;
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, HEX00_gc_commonDatInit)(void) {
}

