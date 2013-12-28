//
//  CPPanGestureTransition.m
//  PassPalette
//
//  Created by wangyw on 12/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPanGestureTransition.h"

@implementation CPPanGestureTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    //get a reference to the final frame of the toViewController **BOILERPLATE
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    //get a reference to the transtion context's container view (where the animation actually happens) **BOILERPLATE
    UIView *containerView = [transitionContext containerView];
    
    CGRect startFram = finalFrame;
    startFram.origin.y = startFram.origin.y - startFram.size.height;
    toViewController.view.frame = startFram;
    [containerView addSubview:toViewController.view];
    [UIView animateWithDuration:0.5 animations:^{
        toViewController.view.frame = finalFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
    }];
}

@end
