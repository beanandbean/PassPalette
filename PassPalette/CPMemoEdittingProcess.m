//
//  CPEditingMemoCellProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoEdittingProcess.h"

@implementation CPMemoEdittingProcess

static CPMemoEdittingProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPMemoEdittingProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
