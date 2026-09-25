/* Small, frequently-called VM value/stack/local helpers, split out of
 * qrun_vm.c into their own translation unit (2026-09-25).
 *
 * Reason: qrun_vm_run() -- the opcode dispatch loop -- alone compiles to
 * well over 32K of 68k code. As long as these helpers were `static`
 * functions defined near the top of the same file, every call to them
 * from deep inside qrun_vm_run() was a same-module bsr that qr68k
 * resolves (and range-checks) immediately at assemble time -- and the
 * word-form range is only +-32K. Moving them here makes every call an
 * external reference instead, resolved by ql68 at link time (with -a
 * falling back to a jump table if still out of range), independent of
 * qrun_vm_run()'s own size. See build_os9_v2.sh for the module split.
 */
#include "qrun_vm.h"
#ifndef QRUN_OS9
#include <stdio.h>
#endif

qrun_value_t* qrun_value_offset(qrun_value_t* base, size_t index)
{
    char* p = (char*)base;
    size_t n = 0;
    while (n < index) {
        p = p + 4;
        n++;
    }
    return (qrun_value_t*)p;
}

void qrun_value_store(qrun_value_t* base, size_t index, qrun_value_t value)
{
    qrun_value_t* p = qrun_value_offset(base, index);
    *p = value;
}

qrun_value_t qrun_value_load(qrun_value_t* base, size_t index)
{
    qrun_value_t* p = qrun_value_offset(base, index);
    return *p;
}

void qrun_push_value(qrun_vm_t* vm, qrun_value_t v)
{
    qrun_stackval_t* stack = vm->stack;
    if (vm->state[QRUN_SP] >= vm->state[QRUN_STACK_SIZE]) {
        fprintf(stderr, "Stack overflow\n");
        vm->state[QRUN_HALTED] = 1;
        return;
    }
    stack[vm->state[QRUN_SP]].val = v;
    vm->state[QRUN_SP]++;
}

qrun_value_t qrun_pop_value(qrun_vm_t* vm)
{
    qrun_stackval_t* stack = vm->stack;
    if (vm->state[QRUN_SP] == 0) {
        fprintf(stderr, "Stack underflow\n");
        vm->state[QRUN_HALTED] = 1;
        return 0;
    }
    vm->state[QRUN_SP]--;
    return stack[vm->state[QRUN_SP]].val;
}

qrun_value_t qrun_peek_value(qrun_vm_t* vm)
{
    qrun_stackval_t* stack = vm->stack;
    if (vm->state[QRUN_SP] == 0) return 0;
    return stack[vm->state[QRUN_SP] - 1].val;
}

int qrun_type_size(const char* type)
{
    if (!type) return 4;
    if (type[0] == 'c' || type[0] == 'b') return 1;  /* char/byte */
    if (type[0] == 'h') return 2;  /* short */
    if (type[0] == 'p') return 8;  /* pointer */
    return 4;  /* default int */
}

qrun_value_t qrun_load_local(qrun_vm_t* vm, int slot)
{
    qrun_frame_t* frames = vm->frames;
    if (vm->state[QRUN_FP] == 0) {
        fprintf(stderr, "No active frame\n");
        return 0;
    }

    size_t frame_idx = vm->state[QRUN_FP] - 1;
    if (slot < 0 || slot >= (int)QRUN_FRAME_AT(frames, frame_idx).nlocals_allocated) {
        fprintf(stderr, "Local slot out of bounds: %d\n", slot);
        return 0;
    }

    return QRUN_FRAME_AT(frames, frame_idx).locals[slot];
}

void qrun_store_local(qrun_vm_t* vm, int slot, qrun_value_t val)
{
    qrun_frame_t* frames = vm->frames;
    if (vm->state[QRUN_FP] == 0) {
        fprintf(stderr, "No active frame\n");
        return;
    }

    size_t frame_idx = vm->state[QRUN_FP] - 1;
    if (slot < 0 || slot >= (int)QRUN_FRAME_AT(frames, frame_idx).nlocals_allocated) {
        fprintf(stderr, "Local slot out of bounds: %d\n", slot);
        return;
    }

    QRUN_FRAME_AT(frames, frame_idx).locals[slot] = val;
}
