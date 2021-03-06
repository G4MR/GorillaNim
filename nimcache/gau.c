/* Generated by Nim Compiler v0.10.3 */
/*   (c) 2015 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Windows, i386, gcc */
/* Command for C compiler:
   gcc.exe -c  -w  -ID:\Nim\lib -o d:\documents\projects\github\gorilla\nimcache\gau.o d:\documents\projects\github\gorilla\nimcache\gau.c */
#define NIM_INTBITS 32
#include "nimbase.h"
typedef struct TGenericSeq TGenericSeq;
typedef struct NimStringDesc NimStringDesc;
typedef struct gaumanager95208 gaumanager95208;
typedef struct gamixer93343 gamixer93343;
typedef struct gaformat93178 gaformat93178;
typedef struct gclink93144 gclink93144;
typedef struct gcmutex92270 gcmutex92270;
struct  TGenericSeq  {
NI len;
NI reserved;
};
struct  NimStringDesc  {
  TGenericSeq Sup;
NIM_CHAR data[SEQ_DECL_SIZE];
};
typedef N_CDECL_PTR(gaumanager95208*, TY95225) (NI32 indevtype, NI32 inthreadpolicy, NI32 innumbuffers, NI32 inbuffersamples);
typedef N_CDECL_PTR(gamixer93343*, TY95242) (gaumanager95208* inmgr);
struct  gaumanager95208  {
char dummy;
};
struct  gaformat93178  {
NI32 Samplerate;
NI32 Bitspersample;
NI32 Numchannels;
};
struct  gclink93144  {
gclink93144* Next;
gclink93144* Prev;
void* Data;
};
struct  gamixer93343  {
gaformat93178 Format;
gaformat93178 Mixformat;
NI32 Numsamples;
NI32* Mixbuffer;
gclink93144 Dispatchlist;
gcmutex92270* Dispatchmutex;
gclink93144 Mixlist;
gcmutex92270* Mixmutex;
};
struct  gcmutex92270  {
void* Mutex;
};
N_NIMCALL(void*, nimLoadLibrary)(NimStringDesc* path);
N_NOINLINE(void, nimLoadLibraryError)(NimStringDesc* path);
N_NIMCALL(void*, nimGetProcAddr)(void* lib, NCSTRING name);
static N_INLINE(void, nimFrame)(TFrame* s);
N_NOINLINE(void, stackoverflow_19601)(void);
static N_INLINE(void, popFrame)(void);
STRING_LITERAL(TMP150, "gorilla.dll", 11);
STRING_LITERAL(TMP151, "gorilla.dll", 11);
static void* TMP149;
TY95225 Dl_95224;
TY95242 Dl_95241;
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
NIM_EXTERNC N_NOINLINE(void, HEX00_gauInit)(void) {
	nimfr("gau", "gau.nim")
	popFrame();
}

NIM_EXTERNC N_NOINLINE(void, HEX00_gauDatInit)(void) {
if (!((TMP149 = nimLoadLibrary((NimStringDesc*) &TMP150))
)) nimLoadLibraryError((NimStringDesc*) &TMP151);
	Dl_95224 = (TY95225) nimGetProcAddr(TMP149, "gau_manager_create_custom");
	Dl_95241 = (TY95242) nimGetProcAddr(TMP149, "gau_manager_mixer");
}

