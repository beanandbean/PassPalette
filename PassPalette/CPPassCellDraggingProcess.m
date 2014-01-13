//
//  CPDraggingPassCellProcess.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCellDraggingProcess.h"

@implementation CPPassCellDraggingProcess

static CPPassCellDraggingProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPPassCellDraggingProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
