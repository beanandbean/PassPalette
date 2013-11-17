//
//  CPEditingPassCellProcess.m
//  Locor
//
//  Created by wangsw on 8/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPEditingPassCellProcess.h"

#import "CPEditingMemoCellProcess.h"
#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

static CPEditingPassCellProcess *g_process;
static NSArray *g_allowedProcess;

@implementation CPEditingPassCellProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPEditingPassCellProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    if (!g_allowedProcess) {
        g_allowedProcess = [NSArray arrayWithObjects:EDITING_MEMO_CELL_PROCESS, REMOVING_MEMO_CELL_PROCESS, SCROLLING_COLLECTION_VIEW_PROCESS, nil];
    }
    return [g_allowedProcess indexOfObject:process] != NSNotFound;
}

@end
