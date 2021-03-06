//
//  CPInteractiveViewManager.h
//  PassPalette
//
//  Created by wangyw on 1/4/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

@interface CPInteractiveViewManager : CPViewManager

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview;

- (void)updateInteractiveTranstionByTranslation:(CGPoint)translation;
- (void)finishInteractiveTranstion;
- (void)cancelInteractiveTransition;

- (void)addBackgroundImageIntoView:(UIView *)view;

@end
