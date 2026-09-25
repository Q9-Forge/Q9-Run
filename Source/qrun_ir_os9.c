/* OS-9 module wrapper - sets QRUN_OS9 before including qrun_ir.c.
 * Compiled as its own translation unit (separate from qrun_vm.c /
 * qrun_main.c) so each becomes its own small ROF module -- a single
 * combined module exceeds the bsr word-branch range (+-32K) that qr68k
 * resolves locally; ql68 -a only fixes up references *between*
 * separately linked modules. */
#define QRUN_OS9 1

#include "qrun_ir.c"
