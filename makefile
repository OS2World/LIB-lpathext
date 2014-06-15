# Makefile to build libray of LIBPATH extension routines using EMX+GCC.
# This makefile is expected to be run using dmake, not gmake or nmake!

# Some nifty options for EMX+GCC
CFLAGS=-c -O3 -D__ST_MT_ERRNO__
LIBFLAGS=/nologo /noignorecase /pagesize:1024
ARFLAGS=-rs

all: lpathext.lib lpathext.a lpathext.inf

lpathext.obj: lpathext.c lpathext.h
	gcc $(CFLAGS) -Zomf -o lpathext.obj lpathext.c

lpathext.lib: lpathext.obj
# Use IBM's library manager for the OMF object module
	lib lpathext.lib $(LIBFLAGS) -+lpathext.obj,,
	+del lpathext.bak

lpathext.o: lpathext.c lpathext.h
	gcc $(CFLAGS) -o lpathext.o lpathext.c

lpathext.a: lpathext.o
	ar $(ARFLAGS) lpathext.a lpathext.o

lpathext.inf: lpathext.ipf
# Use IBM's help/info compiler on the documentation
	ipfc -i -c:850 lpathext.ipf

clean:
# These lines are executed by the shell, with errors ignored
	-+del lpathext.o
	-+del lpathext.obj
	-+del lpathext.bak
