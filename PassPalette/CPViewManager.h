//
//  CPViewManager.h
//  PassPalette
//
//  Created by wangyw on 9/6/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPViewManager : NSObject

@property (weak, nonatomic) CPViewManager *supermanager;
@property (weak, nonatomic) UIView *superview;

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview;

- (void)loadViews;
- (void)unloadViews;

@end
