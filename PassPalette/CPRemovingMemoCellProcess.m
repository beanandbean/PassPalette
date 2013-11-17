//
//  CPRemovingMemoCellProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRemovingMemoCellProcess.h"

static CPRemovingMemoCellProcess *g_process;

@implementation CPRemovingMemoCellProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPRemovingMemoCellProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end

