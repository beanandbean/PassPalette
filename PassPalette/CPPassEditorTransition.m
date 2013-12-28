//
//  CPPassEditorTransition.m
//  PassPalette
//
//  Created by wangyw on 12/26/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorTransition.h"

#import "CPAppearanceManager.h"
#import "CPPassContainerViewController.h"
#import "CPPassEditorViewController.h"

@interface CPPassEditorTransition ()

@property (nonatomic) BOOL reversed;

@end

@implementation CPPassEditorTransition

- (id)initWithReversed:(BOOL)reversed {
    self = [super init];
    if (self) {
        self.reversed = reversed;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CPPassContainerViewController *fromViewController = (CPPassContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    NSAssert(fromViewController != nil, @"");
    
    UIGraphicsBeginImageContextWithOptions(fromViewController.view.bounds.size, NO, fromViewController.view.window.screen.scale);
    [fromViewController.view drawViewHierarchyInRect:fromViewController.view.frame afterScreenUpdates:NO];
    UIImageView *snapshotView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    //get a reference to the final frame of the toViewController **BOILERPLATE
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    //get a reference to the transtion context's container view (where the animation actually happens) **BOILERPLATE
    UIView *containerView = [transitionContext containerView];
    if (self.reversed) {
        [containerView addSubview:toViewController.view];
        [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        return;
    }
    
    snapshotView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:snapshotView];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:snapshotView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:snapshotView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:snapshotView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:snapshotView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [containerView addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
    [containerView layoutIfNeeded];
    
    CGRect cellFrame = fromViewController.selectedPasswordFrame;
    CGRect destFrame = containerView.bounds;
    CGFloat xScale = destFrame.size.width / cellFrame.size.width;
    CGFloat yScale = destFrame.size.height / cellFrame.size.height;
    leftConstraint.constant = - cellFrame.origin.x * xScale - 5;
    rightConstraint.constant = (destFrame.size.width - cellFrame.origin.x - cellFrame.size.width) * xScale + 5;
    topConstraint.constant = - cellFrame.origin.y * yScale - 5;
    bottomConstraint.constant = (destFrame.size.height - cellFrame.origin.y - cellFrame.size.height) * yScale + 5;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] / 2 animations:^{
        [containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        [containerView addSubview:toViewController.view];
        CGRect startFram = finalFrame;
        startFram.origin.y = startFram.origin.y - startFram.size.height;
        toViewController.view.frame = startFram;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] / 2 animations:^{
            toViewController.view.frame = finalFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition: ![transitionContext transitionWasCancelled]];
        }];
    }];
}

@end
