//
//  CPProcessManager.m
//  PassPalette
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcessManager.h"

#import "CPApplicationProcess.h"

// #define NO_PROCESS_LOG

#define PROCESS_ARRAY [CPProcessManager processArray]

@implementation CPProcessManager

static NSMutableArray *g_processArray;
static int g_forbiddenCount = 0;

+ (NSMutableArray *)processArray {
    if (!g_processArray) {
        g_processArray = [NSMutableArray arrayWithObject:APPLICATION_PROCESS];
    }
    return g_processArray;
}

+ (bool)isCurrentProcess:(id<CPProcess>)process {
    return ([PROCESS_ARRAY lastObject] == process);
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

+ (bool)stopProcess:(id<CPProcess>)process {
    if (!g_forbiddenCount && process != APPLICATION_PROCESS) {
        if ([self isCurrentProcess:process]) {
            [PROCESS_ARRAY removeLastObject];
            return YES;
        }
    }
    
#ifndef NO_PROCESS_LOG
    NSLog(@"Try to stop process \"%@\" not succeed.\nCurrent stack: %@", NSStringFromClass([process class]), PROCESS_ARRAY);
#endif
    
    return NO;
}

+ (void)increaseForbiddenCount {
    g_forbiddenCount++;
}

+ (void)decreaseForbiddenCount {
    if (g_forbiddenCount > 0) {
        g_forbiddenCount--;
    }
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    [self increaseForbiddenCount];
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        [self decreaseForbiddenCount];
    }];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    [self increaseForbiddenCount];
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        [self decreaseForbiddenCount];
        if (completion) {
            completion(finished);
        }
    }];
}

@end
