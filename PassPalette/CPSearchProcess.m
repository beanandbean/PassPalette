//
//  CPSearchProcess.m
//  PassPalette
//
//  Created by wangyw on 1/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSearchProcess.h"

@implementation CPSearchProcess

static CPSearchProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPSearchProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
