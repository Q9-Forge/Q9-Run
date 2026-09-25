/* Shared implementations for the small OS-9-local stand-ins declared in
 * qrun_os9.h (strcmp, isspace). Split into their own translation unit
 * (2026-09-25) so there is exactly ONE copy in the linked program instead
 * of one `static` copy per including file -- see qrun_os9.h for why that
 * mattered (bsr range in large modules calling strcmp repeatedly). */
#ifdef QRUN_OS9
/* No #include "qrun_os9.h" here: qcc treats the extern prototype there
 * plus this definition as a "duplicate function" -- the definition alone
 * is a valid declaration too, so every other file gets the prototype from
 * qrun_os9.h and this file just doesn't need it for itself. */

int strcmp(const char* a, const char* b)
{
    while (*a && *a == *b) {
        a++;
        b++;
    }
    return (unsigned char)*a - (unsigned char)*b;
}

int isspace(int c)
{
    return c == 32 || c == 9 || c == 10 || c == 13 || c == 11 || c == 12;
}
#endif
