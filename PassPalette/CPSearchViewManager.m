//
//  CPSearchViewManager.m
//  PassPalette
//
//  Created by wangyw on 1/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSearchViewManager.h"

#import "CPConstraintHelper.h"
#import "CPMainViewController.h"

@interface CPSearchViewManager ()

@property (strong, nonatomic) UIView *searchBarPanel;
@property (strong, nonatomic) NSLayoutConstraint *searchBarPanelBottomConstraint;

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation CPSearchViewManager

- (void)loadViews {
    [self.superview addSubview:self.searchBarPanel];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.searchBarPanel alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:self.searchBarPanelBottomConstraint];
    
    [self.searchBarPanel addSubview:self.searchBar];
    [self.searchBarPanel addConstraints:[CPConstraintHelper constraintsWithView:self.searchBar alignToView:self.searchBarPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.searchBarPanel addConstraint:[CPConstraintHelper constraintWithView:self.searchBar alignToView:self.searchBarPanel attribute:NSLayoutAttributeTop constant:[CPMainViewController mainViewController].topLayoutGuide.length]];
    [self.searchBarPanel addConstraint:[CPConstraintHelper constraintWithView:self.searchBar alignToView:self.searchBarPanel attribute:NSLayoutAttributeBottom]];
    
    // create line on the bottom of search bar
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor grayColor];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [self.searchBarPanel addSubview:line];
    [self.searchBarPanel addConstraints:[CPConstraintHelper constraintsWithView:line alignToView:self.searchBarPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.searchBarPanel addConstraint:[CPConstraintHelper constraintWithView:line alignToView:self.searchBarPanel attribute:NSLayoutAttributeBottom]];
    [line addConstraint:[CPConstraintHelper constraintWithView:line height:1]];
}

- (void)updateByTranslation:(CGPoint)translation {
    self.searchBarPanelBottomConstraint.constant += translation.y;
    if (self.searchBarPanelBottomConstraint.constant > self.searchBarPanel.bounds.size.height) {
        self.searchBarPanelBottomConstraint.constant = self.searchBarPanel.bounds.size.height;
    }
}

// create snapshot view for pass container
/*UIImageView *snapshot = [self createSnapshot];
snapshot.translatesAutoresizingMaskIntoConstraints = NO;
[self.searchView addSubview:snapshot];

[self.searchView addConstraints:[CPConstraintHelper constraintsWithView:snapshot alignToView:self.searchView attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeHeight, ATTR_END]];
self.snapshotTopLayoutConstraint = [CPConstraintHelper constraintWithView:snapshot alignToView:self.searchView attribute:NSLayoutAttributeTop constant:64.0];
[self.searchView addConstraint:self.snapshotTopLayoutConstraint];*/

// [self.settingView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];


#pragma mark - lazy init

- (UIView *)searchBarPanel {
    if (!_searchBarPanel) {
        _searchBarPanel = [[UIView alloc] init];
        _searchBarPanel.backgroundColor = [UIColor clearColor];
        _searchBarPanel.clipsToBounds = YES;
        _searchBarPanel.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImageView *background = [[UIImageView alloc] initWithImage:self.bluredBackgroundImage];
        background.translatesAutoresizingMaskIntoConstraints = NO;
        [_searchBarPanel addSubview:background];
        [_searchBarPanel addConstraints:[CPConstraintHelper constraintsWithView:background alignToView:_searchBarPanel attributes:NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    }
    return _searchBarPanel;
}

- (NSLayoutConstraint *)searchBarPanelBottomConstraint {
    if (!_searchBarPanelBottomConstraint) {
        _searchBarPanelBottomConstraint = [CPConstraintHelper constraintWithView:self.searchBarPanel attribute:NSLayoutAttributeBottom alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    }
    return _searchBarPanelBottomConstraint;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.barTintColor = [UIColor clearColor];
        _searchBar.showsCancelButton = YES;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchBar;
}

@end
