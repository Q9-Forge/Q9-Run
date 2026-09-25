/* OS-9 module wrapper - sets QRUN_OS9 before including qrun_os9support.c.
 * See qrun_ir_os9.c for why this is split into its own module. */
#define QRUN_OS9 1

#include "qrun_os9support.c"
