//
//  CPInteractiveViewManager.m
//  PassPalette
//
//  Created by wangyw on 1/4/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPInteractiveViewManager.h"

#import "CPConstraintHelper.h"

@interface CPInteractiveViewManager ()

@property (strong, nonatomic) UIImage *bluredBackgroundImage;

@end

@implementation CPInteractiveViewManager

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.bluredBackgroundImage = bluredBackgroundImage;
    }
    return self;
}

-(void)updateInteractiveTranstionByTranslation:(CGPoint)translation {
}

-(void)finishInteractiveTranstion {
}

- (void)cancelInteractiveTransition {
}

- (void)addBackgroundImageIntoView:(UIView *)view {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:self.bluredBackgroundImage];
    backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:backgroundImageView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:backgroundImageView edgesAlignToView:self.superview]];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.alpha = 0.5;
    maskView.backgroundColor = [UIColor whiteColor];
    maskView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:maskView];
    [view addConstraints:[CPConstraintHelper constraintsWithView:maskView edgesAlignToView:view]];
}

@end
