//
//  CPSettingsManager.m
//  PassPalette
//
//  Created by wangyw on 11/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsManager.h"

#import "CPConstraintHelper.h"
#import "CPProcessManager.h"

@interface CPSettingsManager ()

@property (strong, nonatomic) UIView *settingsPanel;
@property (strong, nonatomic) NSLayoutConstraint *settingsPanelTopConstraint;

@end

@implementation CPSettingsManager

- (void)loadViewsWithAnimation {
    [self.superview addSubview:self.settingsPanel];
    [self.settingsPanel addConstraint:[CPConstraintHelper constraintWithView:self.settingsPanel height:300.0]];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.settingsPanel alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:self.settingsPanelTopConstraint];
    [self addBackgroundImageIntoView:self.settingsPanel];
    
    [self.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
}

- (void)unloadViewsWithAnimation {
    self.settingsPanelTopConstraint.constant = 0.0;
    [CPProcessManager animateWithDuration:0.3 animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.supermanager dismissSubviewManager:self];
    }];
}

- (void)updateInteractiveTranstionByTranslation:(CGPoint)translation {
    self.settingsPanelTopConstraint.constant += translation.y;
    if (self.settingsPanelTopConstraint.constant < -self.settingsPanel.bounds.size.height) {
        self.settingsPanelTopConstraint.constant = -self.settingsPanel.bounds.size.height;
    }
}

- (void)finishInteractiveTranstion {
    if (self.settingsPanelTopConstraint.constant > -self.settingsPanel.bounds.size.height) {
        self.settingsPanelTopConstraint.constant = -self.settingsPanel.bounds.size.height;
    }
    [CPProcessManager animateWithDuration:0.3 animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)cancelInteractiveTransition {
    self.settingsPanelTopConstraint.constant = 0.0;
    [CPProcessManager animateWithDuration:0.3 animations:^{
        [self.settingsPanel layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.supermanager dismissSubviewManager:self];
    }];
}

- (void)handleTapGesture:(UIPanGestureRecognizer *)tapGesture {
    [self unloadViewsWithAnimation];
}

#pragma mark - lazy init

- (UIView *)settingsPanel {
    if (!_settingsPanel) {
        _settingsPanel = [[UIView alloc] init];
        _settingsPanel.backgroundColor = [UIColor clearColor];
        _settingsPanel.clipsToBounds = YES;
        _settingsPanel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _settingsPanel;
}

- (NSLayoutConstraint *)settingsPanelTopConstraint {
    if (!_settingsPanelTopConstraint) {
        _settingsPanelTopConstraint = [CPConstraintHelper constraintWithView:self.settingsPanel attribute:NSLayoutAttributeTop alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
    }
    return _settingsPanelTopConstraint;
}

@end
