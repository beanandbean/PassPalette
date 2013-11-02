//
//  CPAppContentManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAppContentManager.h"

#import "CPPassContainerManager.h"

#import "CPAppearanceManager.h"

@interface CPAppContentManager ()

@property (strong, nonatomic) CPPassContainerManager *passContainerManager;

@property (strong, nonatomic) UIView *passContainerView;

@end

@implementation CPAppContentManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passContainerView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passContainerView edgesAlignToView:self.superview]];
    [self.passContainerManager loadAnimated:NO];
}

#pragma mark - lazy init

- (UIView *)passContainerView {
    if (!_passContainerView) {
        _passContainerView = [[UIView alloc] init];
        _passContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passContainerView;
}

- (CPPassContainerManager *)passContainerManager {
    if (!_passContainerManager) {
        _passContainerManager = [[CPPassContainerManager alloc] initWithSupermanager:self andSuperview:self.passContainerView];
    }
    return _passContainerManager;
}

@end
