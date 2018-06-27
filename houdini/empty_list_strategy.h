//
//  empty_list_strategy.h
//  houdini
//
//  Created by Abraham Masri on 06/03/2018.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#ifndef empty_list_strategy
#define empty_list_strategy

#include "strategy_control.h"

size_t kread(uint64_t where, void *p, size_t size);
uint64_t kread_uint64(uint64_t where);
uint32_t kread_uint32(uint64_t where);
size_t kwrite(uint64_t where, const void *p, size_t size);
size_t kwrite_uint64(uint64_t where, uint64_t value);
size_t kwrite_uint32(uint64_t where, uint32_t value);

uint64_t empty_list_get_proc_with_pid(pid_t target_pid, int spawned);
kern_return_t empty_list_post_exploit ();
strategy _empty_list_strategy();

#endif /* empty_list_strategy_h */
