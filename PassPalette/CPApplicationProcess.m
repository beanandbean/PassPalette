//
//  CPApplicationProcess.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

#import "CPPassEdittingProcess.h"
#import "CPPassCellDraggingProcess.h"
#import "CPSearchingProcess.h"
#import "CPSettingsProcess.h"

@implementation CPApplicationProcess

static CPApplicationProcess *g_process;
static NSArray *g_allowedProcess;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPApplicationProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    if (!g_allowedProcess) {
        g_allowedProcess = @[PASS_CELL_DRAGGING_PROCESS, PASS_EDITTING_PROCESS, SEARCHING_PROCESS, SETTINGS_PROCESS];
    }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
