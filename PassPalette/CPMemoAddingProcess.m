//
//  CPMemoAddingProcess.m
//  PassPalette
//
//  Created by wangyw on 1/13/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPMemoAddingProcess.h"

@implementation CPMemoAddingProcess

static CPMemoAddingProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPMemoAddingProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
