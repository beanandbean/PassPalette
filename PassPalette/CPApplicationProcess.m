//
//  CPApplicationProcess.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPApplicationProcess.h"

#import "CPEditingPassCellProcess.h"
#import "CPDraggingPassCellProcess.h"
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
        g_allowedProcess = [NSArray arrayWithObjects:EDITING_PASS_CELL_PROCESS, DRAGGING_PASS_CELL_PROCESS, SETTINGS_PROCESS, nil];
    }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
