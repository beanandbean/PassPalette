//
//  CPRootManager.m
//  Passtars
//
//  Created by wangyw on 9/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRootManager.h"

#import "CPAppearanceManager.h"
#import "CPHomeViewManager.h"

@interface CPRootManager ()

@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) CPHomeViewManager *mainViewManager;

@end

@implementation CPRootManager

- (void)loadAnimated:(BOOL)animated {
    /*if ([CPUserDefaultManager isFirstRunning]) {
        [self.superview addSubview:self.helpView];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.helpView edgesAlignToView:self.superview]];
        [self.helpManager loadAnimated:animated];
        
        [CPUserDefaultManager setFirstRuning:NO];
    } else {*/
        [self loadMainViewManager];
    //}
}

- (void)submanagerDidUnload:(CPViewManager *)submanager {
}

- (void)loadMainViewManager {
    [self.superview addSubview:self.mainView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.mainView edgesAlignToView:self.superview]];
    [self.mainViewManager loadAnimated:NO];
}

#pragma mark - lazy init

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] init];
        _mainView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _mainView;
}

- (CPHomeViewManager *)mainViewManager {
    if (!_mainViewManager) {
        _mainViewManager = [[CPHomeViewManager alloc] initWithSupermanager:self andSuperview:self.mainView];
    }
    return _mainViewManager;
}

@end
