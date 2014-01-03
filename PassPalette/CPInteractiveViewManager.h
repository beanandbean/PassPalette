//
//  CPInteractiveViewManager.h
//  PassPalette
//
//  Created by wangyw on 1/3/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

@interface CPInteractiveViewManager : CPViewManager

@property (strong, nonatomic) UIImage *bluredBackgroundImage;

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview;

- (void)updateByTranslation:(CGPoint)translation;

@end
