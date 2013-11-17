//
//  CPEditingMemoCellProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingMemoCellProcess.h"

static CPEditingMemoCellProcess *g_process;

@implementation CPEditingMemoCellProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPEditingMemoCellProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
