//
//  CPDraggingPassCellProcess.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPDraggingPassCellProcess.h"

@implementation CPDraggingPassCellProcess

static CPDraggingPassCellProcess *g_process;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPDraggingPassCellProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end
