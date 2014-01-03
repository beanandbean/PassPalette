//
//  CPInteractiveViewManager.m
//  PassPalette
//
//  Created by wangyw on 1/3/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPInteractiveViewManager.h"

@implementation CPInteractiveViewManager

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.bluredBackgroundImage = bluredBackgroundImage;
    }
    return self;
}

- (void)updateByTranslation:(CGPoint)translation {
}

@end
