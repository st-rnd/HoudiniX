//
//  strategy_control.m
//  houdini
//
//  Created by Abraham Masri on 12/7/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

#include "triple_fetch_strategy.h"
#include "async_wake_strategy.h"
#include "multi_path_strategy.h"
#include "empty_list_strategy.h"
#include "machswap_strategy.h"
#include "machswap_pwn_strategy.h"
#include "strategy_control.h"

strategy chosen_strategy;

// purpose: returns the suitable strategy for the system version
kern_return_t set_exploit_strategy() {
    memset(&chosen_strategy, 0, sizeof(chosen_strategy));
    
    NSString *system_version = [[UIDevice currentDevice] systemVersion];
    
    NSArray *triple_fetch_versions = @[@"10.0", @"10.1", @"10.1.1", @"10.2", @"10.2.1", @"10.3.1"];

    //NSArray *async_wake_versions = @[@"11.0", @"11.0.1", @"11.0.3", @"11.1", @"11.1.2"];
//    NSArray *multi_path_versions = @[@"11.2", @"11.2.1", @"11.3", @"11.3.1"];
    NSArray *empty_list_versions = @[@"11.2", @"11.2.1", @"11.2.2", @"11.2.5", @"11.2.6", @"11.3", @"11.3.1"];
    
    NSArray *machswap_versions = @[@"12.0", @"12.0.1", @"12.1", @"12.1.1", @"12.1.2"];
    
    NSArray *machswap_pwn_devices = @[@"iPhone11,2", @"iPhone11,4", @"iPhone11,6", @"iPhone11,8", @"iPad8,1", @"iPad8,2", @"iPad8,3", @"iPad8,4", @"iPad8,5", @"iPad8,6", @"iPad8,7", @"iPad8,8"];
    
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithUTF8String:machine];
    
    free(machine);
    
    NSLog(@"%@", [@"[INFO] Platform: " stringByAppendingString:platform]);
    
    if ([triple_fetch_versions containsObject:system_version]) {
    
        printf("[INFO]: chose triple_fetch_strategy!\n");
        chosen_strategy = triple_fetch_strategy();
        return KERN_SUCCESS;
        
    }
    /*else if ([async_wake_versions containsObject:system_version]) {

        printf("[INFO]: chose async_wake_strategy!\n");
        chosen_strategy = async_wake_strategy();
        return KERN_SUCCESS;

    }*/
    else if ([empty_list_versions containsObject:system_version]) {
        
        printf("[INFO]: chose empty_list_strategy!\n");
        chosen_strategy = _empty_list_strategy();
        return KERN_SUCCESS;
    }
    else if ([machswap_versions containsObject:system_version]) {
        if ([machswap_pwn_devices containsObject:platform]) {
            printf("[INFO]: chose machswap_pwn!\n");
            chosen_strategy = _machswap_pwn_strategy();
            return KERN_SUCCESS;
        } else {
            printf("[INFO]: chose machswap2!\n");
            chosen_strategy = _machswap_strategy();
            return KERN_SUCCESS;
        }
    }
//    else if ([multi_path_versions containsObject:system_version]) {
//
//        printf("[INFO]: chose multi_path_strategy!\n");
//        chosen_strategy = _multi_path_strategy();
//        return KERN_SUCCESS;
//    }

    printf("[ERROR]: no suitable strategy was chosen!\n");
    return KERN_FAILURE;
}
