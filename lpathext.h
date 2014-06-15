/* Function prototypes for LIBPATH extension functions.     */

/* Copyright (C) 2001, David W. Noon.  All rights reserved. */

#ifndef DWN_LIBPATH_EXTENSIONS_INCLUDED
#define DWN_LIBPATH_EXTENSIONS_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif
unsigned long set_beginlibpath(void);
unsigned long set_endlibpath(void);
unsigned long clear_beginlibpath(void);
unsigned long clear_endlibpath(void);
unsigned long append_beginlibpath(const char * path);
unsigned long append_endlibpath(const char * path);
unsigned long prepend_beginlibpath(const char * path);
unsigned long prepend_endlibpath(const char * path);
unsigned long query_beginlibpath(char * path_list);
unsigned long query_endlibpath(char * path_list);
#ifdef __cplusplus
}
#endif
#endif
