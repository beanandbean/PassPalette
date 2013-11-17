//
//  CPSettingsManager.m
//  PassPalette
//
//  Created by wangyw on 11/3/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPSettingsManager.h"

#import "CPAppearanceManager.h"
#import "CPProcessManager.h"
#import "CPSettingsProcess.h"

@interface CPSettingsManager ()

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation CPSettingsManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.searchBar];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.searchBar alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0]];
    
    UIView *seperator = [[UIView alloc] init];
    seperator.backgroundColor = [UIColor blackColor];
    seperator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:seperator];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:seperator alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [seperator addConstraint:[CPAppearanceManager constraintWithView:seperator height:1.0]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:seperator attribute:NSLayoutAttributeTop alignToView:self.searchBar attribute:NSLayoutAttributeBottom]];
}

#pragma mark - lazy init

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.barTintColor = [UIColor clearColor];
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchBar;
}

@end
