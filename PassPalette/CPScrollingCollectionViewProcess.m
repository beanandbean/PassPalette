//
//  CPScrollingCollectionViewProcess.m
//  Locor
//
//  Created by wangsw on 7/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPScrollingCollectionViewProcess.h"

static CPScrollingCollectionViewProcess *g_process;

@implementation CPScrollingCollectionViewProcess

+ (id<CPProcess>)process {
    if (!g_process) {
        g_process = [[CPScrollingCollectionViewProcess alloc] init];
    }
    return g_process;
}

- (BOOL)allowSubprocess:(id<CPProcess>)process {
    return NO;
}

@end

