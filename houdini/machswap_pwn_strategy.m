//
//  machswap_pwn_strategy.m
//  houdini
//
//  Created by Conor B on 06/04/2019.
//  Copyright © 2019 cheesecakeufo. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <mach/mach.h>
#include "strategy_control.h"
#include "utilities.h"
#include "task_ports.h"
#include <stdio.h>
#include <pthread.h>

#include "machswap/iokit.h"
#include "machswap/common.h"
#include "machswap_pwn/machswap2_pwn.h"
#include "machswap_pwn/machswap_offsets.h"

kern_return_t machswap_pwn_strategy_start () {
    kern_return_t ret;
    
    machswap_offsets_t *offs = get_machswap_offsets();
    if (offs == NULL)
    {
        LOG("failed to get offsets!");
        return KERN_FAILURE;
    }
    
    mach_port_t tfp0;
    uint64_t kernel_base;
    ret = machswap2_exploit(offs, &tfp0, &kernel_base);
    if (ret != KERN_SUCCESS)
    {
        LOG("failed to run exploit: %x %s", ret, mach_error_string(ret));
        return KERN_FAILURE;
    }
    
    LOG("success!");
    LOG("tfp0: %x", tfp0);
    LOG("kernel base: 0x%llx", kernel_base);
    
    return ret;
}

// called after strategy_start - check if we are good to continue
kern_return_t machswap_pwn_strategy_post_exploit () {
    kern_return_t ret;
    
    if (getuid() != 0)
    {
        ret = KERN_FAILURE;
    } else {
        ret = KERN_SUCCESS;
    }
    
    return ret;
}

void machswap_pwn_strategy_mkdir (char *path) {
    machswap_pwn_strategy_post_exploit();
    mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
}

void machswap_pwn_strategy_rename (const char *old, const char *new) {
    machswap_pwn_strategy_post_exploit();
    rename(old, new);
}

void machswap_pwn_strategy_unlink (char *path) {
    machswap_pwn_strategy_post_exploit();
    unlink(path);
}
int machswap_pwn_strategy_chown (const char *path, uid_t owner, gid_t group) {
    machswap_pwn_strategy_post_exploit();
    int ret = chown(path, owner, group);
    return ret;
}


int machswap_pwn_strategy_chmod (const char *path, mode_t mode) {
    machswap_pwn_strategy_post_exploit();
    int ret = chmod(path, mode);
    return ret;
}


int machswap_pwn_strategy_open (const char *path, int oflag, mode_t mode) {
    machswap_pwn_strategy_post_exploit();
    int fd = open(path, oflag, mode);
    
    return fd;
}

void machswap_pwn_strategy_kill (pid_t pid, int sig) {
    kill(pid, sig);
}


void machswap_pwn_strategy_reboot () {
    reboot(0);
}

pid_t machswap_pwn_strategy_pid_for_name(char *name) {
    
    return find_pid_for_path(name);
}

strategy _machswap_pwn_strategy () {
    
    strategy returned_strategy;
    
    memset(&returned_strategy, 0, sizeof(returned_strategy));
    
    returned_strategy.strategy_start = &machswap_pwn_strategy_start;
    returned_strategy.strategy_post_exploit = &machswap_pwn_strategy_post_exploit;
    
    returned_strategy.strategy_mkdir = &machswap_pwn_strategy_mkdir;
    returned_strategy.strategy_rename = &machswap_pwn_strategy_rename;
    returned_strategy.strategy_unlink = &machswap_pwn_strategy_unlink;
    
    returned_strategy.strategy_chown = &machswap_pwn_strategy_chown;
    returned_strategy.strategy_chmod = &machswap_pwn_strategy_chmod;
    
    returned_strategy.strategy_open = &machswap_pwn_strategy_open;
    
    returned_strategy.strategy_kill = &machswap_pwn_strategy_kill;
    returned_strategy.strategy_reboot = &machswap_pwn_strategy_reboot;
    
    returned_strategy.strategy_pid_for_name = &machswap_pwn_strategy_pid_for_name;
    return returned_strategy;
}
