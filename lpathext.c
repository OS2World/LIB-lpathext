/* Subroutine library to manipulate OS/2 LIBPATH extensions.          */

/* You may use this code freely, and redistribute it provided the     */
/* original copyright caveat is retained and no charge is levied      */
/* beyond the price of its distribution medium.                       */

/* No warranty is expressed or implied as to the suitability of this  */
/* software to perform any given task, nor will the author accept     */
/* liability for any damage or loss incurred by its use.              */

/* Copyright (C) 2001, David W. Noon.  All rights reserved.           */

/* To switch off the BIN/DLL directory swap, set this macro to 0. */
#define FIDDLE_BIN_TO_DLL 1

#include <stdlib.h>
#include <string.h>
#if FIDDLE_BIN_TO_DLL
#include <locale.h>
#endif

#define INCL_NOPMAPI
#define INCL_DOSPROCESS
#define INCL_DOSMODULEMGR
#define INCL_DOSMISC
#define INCL_DOSERRORS
#include <os2.h>

#include "lpathext.h"

/* Private subroutine to set either LIBPATH extension. */
static APIRET set_eitherlibpath(ULONG begin_end_flag)
{
   PPIB pib_ptr;
   PTIB tib_ptr;
   APIRET rc;
   PUCHAR first_slash, final_slash, previous_slash;
   UCHAR exe_path[CCHMAXPATH];

   /* Get the address of the thread and process information blocks. */
   DosGetInfoBlocks(&tib_ptr, &pib_ptr);

   /* Get the full path/filename of the executable that started this process. */
   if ((rc = DosQueryModuleName(pib_ptr->pib_hmte, sizeof exe_path, exe_path)) != NO_ERROR)
      return rc;

   /* The path/filename returned will be X:\dir\subdir\...\progname.exe in format. */
   first_slash = &exe_path[2];

   /* Scan the string from right to left for the final '\' or '/', until we hit the first '\' or '/'. */
   final_slash = &exe_path[strlen(exe_path)];
   do
   {
      --final_slash;
   } while (final_slash > first_slash && *final_slash != '\\' && *final_slash != '/');

   /* Check if we hit the left edge of the directory path. */
   if (final_slash == first_slash)
   {
      /* The root directory of a drive is left as is. */
      exe_path[3] = '\0';
   }
   else
   {
      /* Make the final slash before the program name into the end of string. */
      *final_slash = '\0';

      #if FIDDLE_BIN_TO_DLL
      /* See if we should "fiddle" the final node of the path from "BIN" to "DLL". */
      for (previous_slash = final_slash - 1; previous_slash >= first_slash; --previous_slash)
      {
         if (*previous_slash == '\\' || *previous_slash == '/')
         {
            /* Save user's locale. */
            const char * const old_locale = setlocale(LC_CTYPE, NULL);

            /* Ensure a C locale for the strnicmp() call. */
            setlocale(LC_CTYPE, "C");
            if (final_slash - previous_slash == 4 &&
                  strnicmp(previous_slash+1, "bin", 3) == 0)
            {
               const size_t final_node_offset = previous_slash - exe_path + 1;
               UCHAR DLL_path[CCHMAXPATH];

               /* Make the DLL directory name in the new string. */
               strcpy(DLL_path, exe_path);
               DLL_path[final_node_offset] = 'D';
               DLL_path[final_node_offset+1] = 'L';
               DLL_path[final_node_offset+2] = 'L';

               /* See if the DLL directory exists. */
               if (DosQueryPathInfo(DLL_path, FIL_QUERYFULLNAME, DLL_path, sizeof DLL_path)
                     == NO_ERROR)
                  strcpy(exe_path, DLL_path);
            }
            /* Restore user's locale. */
            setlocale(LC_CTYPE, old_locale);

            /* Terminate the surrounding for-loop. */
            break;
         }
      }
      #endif /* FIDDLE_BIN_TO_DLL */
   }

   /* Set the specified LIBPATH extension. */
   return DosSetExtLIBPATH(exe_path, begin_end_flag);
}

/* Private subroutine to append to either LIBPATH extension */
static APIRET append_eitherlibpath(PCSZ path, ULONG begin_end_flag)
{
   const size_t path_len = strlen(path);
   size_t old_path_len;
   APIRET rc;
   UCHAR old_libpath[1024];

   if (path_len == 0)
      return ERROR_INVALID_PARAMETER;

   if (path_len > 1023)
      return ERROR_NOT_ENOUGH_MEMORY;

   if ((rc = DosQueryExtLIBPATH(old_libpath, begin_end_flag)) != NO_ERROR)
      return rc;

   if (old_libpath[0] == '\0')
   {
      memcpy(old_libpath, path, path_len+1);
      old_path_len = path_len - 1;
   }
   else
   {
      /* Use lengths instead of NUL terminators after this. */
      old_path_len = strlen(old_libpath);

      /* Check if the new size is too large. */
      if (path_len + old_path_len > 1022)
         return ERROR_NOT_ENOUGH_MEMORY;

      /* Concatenate the new path, separated by a semi-colon, on the end of the existing paths. */
      if (old_libpath[old_path_len-1] != ';')
         old_libpath[old_path_len++] = ';';
      memcpy(&old_libpath[old_path_len], path, path_len+1);
      old_path_len += path_len - 1;
   }

   /* Erase any trailing semi-colon. */
   if (old_libpath[old_path_len] == ';')
      old_libpath[old_path_len] = '\0';

   return DosSetExtLIBPATH(old_libpath, begin_end_flag);
}

/* Private subroutine to prepend to either LIBPATH extension */
static APIRET prepend_eitherlibpath(PCSZ path, ULONG begin_end_flag)
{
   size_t path_len = strlen(path);
   APIRET rc;
   UCHAR old_libpath[1024], new_libpath[1024];

   if (path_len == 0)
      return ERROR_INVALID_PARAMETER;

   if (path_len > 1023)
      return ERROR_NOT_ENOUGH_MEMORY;

   if ((rc = DosQueryExtLIBPATH(old_libpath, begin_end_flag)) != NO_ERROR)
      return rc;

   memcpy(new_libpath, path, path_len);
   if (old_libpath[0] == '\0')
   {
      /* Remove any trailing semi-colon. */
      if (path[path_len-1] == ';')
         --path_len;

      new_libpath[path_len] = '\0';
   }
   else
   {
      register size_t old_path_len = strlen(old_libpath);

      /* Adjust for any trailing semi-colon returned by API. */
      if (old_libpath[old_path_len-1] == ';')
         old_libpath[--old_path_len] = '\0';

      /* Ensure we have a semi-colon separator. */
      if (path[path_len-1] != ';')
         new_libpath[path_len++] = ';';

      if (path_len + old_path_len > 1023)
         return ERROR_NOT_ENOUGH_MEMORY;

      memcpy(&new_libpath[path_len], old_libpath, old_path_len+1);
   }

   return DosSetExtLIBPATH(new_libpath, begin_end_flag);
}

/* Entry point to set the BEGINLIBPATH extension. */
unsigned long set_beginlibpath(void)
{
   return set_eitherlibpath(BEGIN_LIBPATH);
}

/* Entry point to set the ENDLIBPATH extension. */
unsigned long set_endlibpath(void)
{
   return set_eitherlibpath(END_LIBPATH);
}

/* Entry to clear the BEGINLIBPATH extension */
unsigned long clear_beginlibpath(void)
{
   return DosSetExtLIBPATH("", BEGIN_LIBPATH);
}

/* Entry to clear the ENDLIBPATH extension */
unsigned long clear_endlibpath(void)
{
   return DosSetExtLIBPATH("", END_LIBPATH);
}

/* Entry to append to the BEGINLIBPATH extension */
unsigned long append_beginlibpath(const char * path)
{
   return append_eitherlibpath(path, BEGIN_LIBPATH);
}

/* Entry to append to the ENDLIBPATH extension */
unsigned long append_endlibpath(const char * path)
{
   return append_eitherlibpath(path, END_LIBPATH);
}

/* Entry to prepend to the BEGINLIBPATH extension */
unsigned long prepend_beginlibpath(const char * path)
{
   return prepend_eitherlibpath(path, BEGIN_LIBPATH);
}

/* Entry to prepend to the ENDLIBPATH extension */
unsigned long prepend_endlibpath(const char * path)
{
   return prepend_eitherlibpath(path, END_LIBPATH);
}

/* Entry to query to the BEGINLIBPATH extension */
unsigned long query_beginlibpath(char * path_list)
{
   return DosQueryExtLIBPATH(path_list, BEGIN_LIBPATH);
}

/* Entry to query to the ENDLIBPATH extension */
unsigned long query_endlibpath(char * path_list)
{
   return DosQueryExtLIBPATH(path_list, END_LIBPATH);
}
