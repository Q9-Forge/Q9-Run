#ifndef QRUN_OS9_H
#define QRUN_OS9_H
/* QCC/OS-9 ABI declarations. Do not include host SDK headers here. */
typedef int int32_t;
typedef unsigned int uint32_t;
typedef unsigned int size_t;
typedef int FILE;
#define NULL 0
static FILE* stderr;
extern FILE* fopen(const char*, const char*);
extern int fclose(FILE*);
extern char* fgets(char*, int, FILE*);
extern int fprintf(FILE*, const char*, ...);
extern int printf(const char*, ...);
extern int putchar(int);
extern int putint(int);
extern void* malloc(size_t);
extern void* calloc(size_t, size_t);
extern void* realloc(void*, size_t);
extern void free(void*);
extern int atoi(const char*);
extern size_t strlen(const char*);
/* Microware's strcmp entry is not reliably callable through the current
   external-call bridge.  Keep this fundamental parser operation local (no
   OS-9 dependency, preserves the standard strcmp contract) -- but as a
   single shared definition in qrun_os9support.c, not duplicated `static`
   per file: a `static` copy in this header meant every module got its own,
   and with enough call sites spread across a large module (e.g.
   qrun_vm.c) the bsr to that local copy exceeded qr68k's +-32K word-branch
   range. Same reasoning for isspace() below. See qrun_os9support.c. */
extern int strcmp(const char* a, const char* b);
extern int strncmp(const char*, const char*, size_t);
extern char* strcpy(char*, const char*);
extern char* strchr(const char*, int);
extern char* strstr(const char*, const char*);
extern void* memset(void*, int, size_t);
extern int isspace(int c);
#endif
