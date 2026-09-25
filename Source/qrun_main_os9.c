/* OS-9 module wrapper - sets QRUN_OS9 before including qrun_main.c.
 * See qrun_ir_os9.c for why this is split into its own module. */
#define QRUN_OS9 1

#include "qrun_main.c"
