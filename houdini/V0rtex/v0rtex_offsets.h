//
//  offsets.h
//  houdini
//
//  Created by Eloghosa Ogbemudia on 4/7/19.
//  Copyright © 2019 cheesecakeufo. All rights reserved.
//

#ifndef offsets_h
#define offsets_h


#endif /* offsets_h */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include "v0rtexCommon.h"

extern UInt64 OFFSET_ZONE_MAP;
extern UInt64 OFFSET_KERNEL_MAP;
extern UInt64 OFFSET_KERNEL_TASK;
extern UInt64 OFFSET_REALHOST;
extern UInt64 OFFSET_BZERO;
extern UInt64 OFFSET_BCOPY;
extern UInt64 OFFSET_COPYIN;
extern UInt64 OFFSET_COPYOUT;
extern UInt64 OFFSET_IPC_PORT_ALLOC_SPECIAL;
extern UInt64 OFFSET_IPC_KOBJECT_SET;
extern UInt64 OFFSET_IPC_PORT_MAKE_SEND;
extern UInt64 OFFSET_IOSURFACEROOTUSERCLIENT_VTAB;
extern UInt64 OFFSET_ROP_ADD_X0_X0_0x10;
extern UInt64 OFFSET_ROOTVNODE;
extern UInt64 OFFSET_CHGPROCCNT;
extern UInt64 OFFSET_KAUTH_CRED_REF;
extern UInt64 OFFSET_OSSERIALIZER_SERIALIZE;
extern UInt64 OFFSET_ROP_LDR_X0_X0_0x10;
void load_offsets(void);
