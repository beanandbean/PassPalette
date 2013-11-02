//
//  CPProcessManager.m
//  Passtars
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPApplicationProcess.h"

#define NO_PROCESS_LOG

#define PROCESS_ARRAY [CPProcessManager processArray]

static NSMutableArray *g_processArray;
static int g_forbiddenCount = 0;

@implementation CPProcessManager

+ (NSMutableArray *)processArray {
    if (!g_processArray) {
        g_processArray = [NSMutableArray arrayWithObject:APPLICATION_PROCESS];
    }
    return g_processArray;
}

+ (bool)isInProcess:(id<CPProcess>)process {
    return [PROCESS_ARRAY indexOfObject:process] != NSNotFound;
}

+ (bool)startProcess:(id<CPProcess>)process {
    if (!g_forbiddenCount && [[PROCESS_ARRAY lastObject] allowSubprocess:process]) {
        [PROCESS_ARRAY addObject:process];
        return YES;
    } else {
        
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
        
        return NO;
    }
}

+ (bool)startProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if (START_PROCESS(process)) {
        // Preparation process provides not REQUIRED protect, so there's no need to check if it is started successfully.
        INCREASE_FORBIDDEN_COUNT;
        preparation();
        DECREASE_FORBIDDEN_COUNT;
        return YES;
    } else {
        
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to start process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
        
        return NO;
    }
}

+ (bool)stopProcess:(id<CPProcess>)process {
    if (!g_forbiddenCount && process != APPLICATION_PROCESS) {
        NSUInteger index = PROCESS_ARRAY.count - 1;
        while (index > 0 && [PROCESS_ARRAY objectAtIndex:index] != process) {
            index--;
        }
        if (index > 0 && (index == PROCESS_ARRAY.count - 1 || [[PROCESS_ARRAY objectAtIndex:index - 1] allowSubprocess:[PROCESS_ARRAY objectAtIndex:index + 1]])) {
            [PROCESS_ARRAY removeObjectAtIndex:index];
            return YES;
        }
    }
    
#ifndef NO_PROCESS_LOG
    NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
    
    return NO;
}

+ (bool)stopProcess:(id<CPProcess>)process withPreparation:(void (^)(void))preparation {
    if (STOP_PROCESS(process)) {
        INCREASE_FORBIDDEN_COUNT;
        preparation();
        DECREASE_FORBIDDEN_COUNT;
        return YES;
    } else {
    
#ifndef NO_PROCESS_LOG
        NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
    
        return NO;
    }
}

+ (void)increaseForbiddenCount {
    g_forbiddenCount++;
}

+ (void)decreaseForbiddenCount {
    if (g_forbiddenCount > 0) {
        g_forbiddenCount--;
    }
}

@end
