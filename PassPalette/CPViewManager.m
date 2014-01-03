//
//  CPViewManager.m
//  PassPalette
//
//  Created by wangyw on 9/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

@implementation CPViewManager

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super init];
    if (self) {
        self.supermanager = supermanager;
        self.superview = superview;
    }
    return self;
}

- (void)loadViews {
}

- (void)unloadViews {
}

@end
