/* file fsalib_wrapper.c  18/01/19
 *
 * This file is a wrapper for a shared and a static library. It provides
 * proper definitions used while linking a library.
 *
 */

#include "defs.h"
#include "../src/definitions.h"

/* The following line was imported from the ../src/kbprog.c file */
boolean kbm_onintr = FALSE;   /* set true on interrupt signal */
