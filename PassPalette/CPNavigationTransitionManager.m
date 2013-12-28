//
//  CPNavigationTransitionManager.m
//  PassPalette
//
//  Created by wangyw on 12/26/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPNavigationTransitionManager.h"

#import "CPPassEditorTransition.h"

@implementation CPNavigationTransitionManager

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return [[CPPassEditorTransition alloc] init];
}

@end
