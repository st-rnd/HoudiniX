#ifndef PWN_H
#define PWN_H

#include <mach/mach.h>

#include "common.h"

mach_port_t exploit(machswap_offsets_t *offsets, task_t *tfp0_back, uint64_t *kbase_back);

#endif
