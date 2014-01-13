//
//  CPEditingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 8/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEdittingProcess.h"

#import "CPMemoAddingProcess.h"
#import "CPMemoEdittingProcess.h"
#import "CPRemovingMemoCellProcess.h"

@implementation CPPassEdittingProcess

static CPPassEdittingProcess *g_process;
static NSArray *g_allowedProcess;

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPPassEdittingProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    if (!g_allowedProcess) {
        g_allowedProcess = @[MEMO_ADDING_PROCESS, MEMO_EDITTING_PROCESS, REMOVING_MEMO_CELL_PROCESS];
    }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
