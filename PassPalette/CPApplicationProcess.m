//
//  CPApplicationProcess.m
//  Passtars
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

// #import "CPDraggingPassViewProcess.h"

static CPApplicationProcess *g_process;
static NSArray *g_allowedProcess;

@implementation CPApplicationProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPApplicationProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    // if (!g_allowedProcess) {
    //     g_allowedProcess = [NSArray arrayWithObjects:DRAGGING_PASS_VIEW_PROCESS, nil];
    // }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
