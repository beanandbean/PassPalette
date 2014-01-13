//
//  CPSearchProcess.m
//  PassPalette
//
//  Created by wangyw on 1/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSearchingProcess.h"

@implementation CPSearchingProcess

static CPSearchingProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPSearchingProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
