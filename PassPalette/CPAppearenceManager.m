//
//  CPAppearenceManager.m
//  PassPalette
//
//  Created by wangyw on 1/19/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPAppearenceManager.h"

#import "CPRainbow.h"

@implementation CPAppearenceManager

static CPAppearenceManager *g_defaultManager = nil;

+ (CPAppearenceManager *)defaultManager {
    if (!g_defaultManager) {
        g_defaultManager = [[CPAppearenceManager alloc] init];
    }
    return g_defaultManager;
}

#pragma mark - lazy init

- (id<CPColorTable>)colorTable {
    if (!_colorTable) {
        _colorTable = [[CPRainbow alloc] init];
    }
    return _colorTable;
}

@end
