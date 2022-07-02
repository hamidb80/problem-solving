#include <stdio.h>
#include <string.h>
#include <rt_misc.h>
#include <rt_sys.h>
#include <File_Config.h>
#include "Modules.h"

//#pragma import(__use_no_semihosting_swi)

/* The following macro definitions may be used to translate this file:

  STDIO - use standard Input/Output device
          (default is NOT used)
 */
#if PROJECT_USE_SDCARD
/* Standard IO device handles. */
#define STDIN   0x8001
#define STDOUT  0x8002
#define STDERR  0x8003

// /* Standard IO device name defines. */
// extern const char __stdin_name[]  = "STDIN";
// extern const char __stdout_name[] = "STDOUT";
// extern const char __stderr_name[] = "STDERR";

struct __FILE { int handle; /* Add whatever you need here */ };

#ifdef STDIO
/*----------------------------------------------------------------------------
  Write character to Serial Port
 *----------------------------------------------------------------------------*/
int sendchar (int c) {
    system.uart.Send(3, c);
		return (c);
}


/*----------------------------------------------------------------------------
  Read character from Serial Port   (blocking read)
 *----------------------------------------------------------------------------*/
int getkey (void) {

  return (system.uart.Get(3));
}
#endif

/*--------------------------- _ttywrch --------------------------------------*/

void _ttywrch (int ch) {
#ifdef STDIO
  sendchar(ch);
#endif
}

/*--------------------------- _sys_open -------------------------------------*/

// FILEHANDLE _sys_open (const char *name, int openmode) {
//   /* Register standard Input Output devices. */
//   if (strcmp(name, "STDIN") == 0) {
//     return (STDIN);
//   }
//   if (strcmp(name, "STDOUT") == 0) {
//     return (STDOUT);
//   }
//   if (strcmp(name, "STDERR") == 0) {
//     return (STDERR);
//   }
//   return (__fopen (name, openmode));
// }

/*--------------------------- _sys_close ------------------------------------*/

// int _sys_close (FILEHANDLE fh) {
//   if (fh > 0x8000) {
//     return (0);
//   }
//   return (__fclose (fh));
// }

/*--------------------------- _sys_write ------------------------------------*/

// int _sys_write (FILEHANDLE fh, const U8 *buf, U32 len, int mode) {
// #ifdef STDIO
//   if (fh == STDOUT) {
//     /* Standard Output device. */
//     for (  ; len; len--) {
//       sendchar (*buf++);
//     }
//     return (0);
//   }
// #endif
//   if (fh > 0x8000) {
//     return (-1);
//   }
//   return (__write (fh, buf, len));
// }

/*--------------------------- _sys_read -------------------------------------*/

// int _sys_read (FILEHANDLE fh, U8 *buf, U32 len, int mode) {
// #ifdef STDIO
//   if (fh == STDIN) {
//     /* Standard Input device. */
//     for (  ; len; len--) {
//       *buf++ = getkey ();
//     }
//     return (0);
//   }
// #endif
//   if (fh > 0x8000) {
//     return (-1);
//   }
//   return (__read (fh, buf, len));
// }

/*--------------------------- _sys_istty ------------------------------------*/

// int _sys_istty (FILEHANDLE fh) {
//   if (fh > 0x8000) {
//     return (1);
//   }
//   return (0);
// }

/*--------------------------- _sys_seek -------------------------------------*/

// int _sys_seek (FILEHANDLE fh, long pos) {
//   if (fh > 0x8000) {
//     return (-1);
//   }
//   return (__setfpos (fh, pos));
// }

/*--------------------------- _sys_ensure -----------------------------------*/

// int _sys_ensure (FILEHANDLE fh) {
//   if (fh > 0x8000) {
//     return (-1);
//   }
//   return (__flushbuf (fh));
// }

/*--------------------------- _sys_flen -------------------------------------*/

// long _sys_flen (FILEHANDLE fh) {
//   if (fh > 0x8000) {
//     return (0);
//   }
//   return (__get_flen (fh));
// }

/*--------------------------- _sys_tmpnam -----------------------------------*/

int _sys_tmpnam (char *name, int sig, unsigned maxlen) {
  return (1);
}

/*--------------------------- _sys_command_string ---------------------------*/

char *_sys_command_string (char *cmd, int len) {
  return (cmd);
}

#endif

void _sys_exit (int return_code) {
  /* Endless loop. */
  while (1);
}
