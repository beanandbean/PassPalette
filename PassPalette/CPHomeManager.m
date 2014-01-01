//
//  CPHomeManager.m
//  PassPalette
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHomeManager.h"

#import "CPAdManager.h"
#import "CPConstraintHelper.h"
#import "CPPassContainerManager.h"
#import "CPProcessManager.h"

@interface CPHomeManager ()

@property (strong, nonatomic) UIView *passView;
@property (strong, nonatomic) CPPassContainerManager *passContainerManager;

@property (strong, nonatomic) UIView *adView;
@property (strong, nonatomic) CPAdManager *adManager;

@end

@implementation CPHomeManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passView alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, ATTR_END]];
    
    [self.superview addSubview:self.adView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.adView alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[CPConstraintHelper constraintWithView:self.passView attribute:NSLayoutAttributeBottom alignToView:self.adView attribute:NSLayoutAttributeTop]];
    
    [self.passContainerManager loadAnimated:NO];
    [self.adManager loadAnimated:NO];
}

#pragma mark - lazy init

- (UIView *)passView {
    if (!_passView) {
        _passView = [[UIView alloc] init];
        _passView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passView;
}

- (CPPassContainerManager *)passContainerManager {
    if (!_passContainerManager) {
        _passContainerManager = [[CPPassContainerManager alloc] initWithSupermanager:self andSuperview:self.passView];
    }
    return _passContainerManager;
}

- (UIView *)adView {
    if (!_adView) {
        _adView = [[UIView alloc] init];
        _adView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _adView;
}

- (CPAdManager *)adManager {
    if (!_adManager) {
        _adManager = [[CPAdManager alloc] initWithSupermanager:self andSuperview:self.adView];
    }
    return _adManager;
}

@end
