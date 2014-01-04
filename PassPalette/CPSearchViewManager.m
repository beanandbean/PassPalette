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
#import "CPMemoCell.h"
#import "CPPassContainerManager.h"
#import "CPProcessManager.h"

@interface CPSearchViewManager ()

@property (strong, nonatomic) UIImage *bluredBackgroundImage;

@property (strong, nonatomic) UIView *searchBarPanel;
@property (strong, nonatomic) NSLayoutConstraint *searchBarPanelBottomConstraint;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UIView *resultCollectionViewPanel;
@property (strong, nonatomic) UICollectionView *resultCollectionView;

@end

@implementation CPSearchViewManager

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.bluredBackgroundImage = bluredBackgroundImage;
    }
    return self;
}

- (void)loadViewsWithAnimation {
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

- (void)unloadViewsWithAnimation {
    [self.searchBar resignFirstResponder];
    [CPProcessManager animateWithDuration:0.3 animations:^{
        self.resultCollectionViewPanel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.searchBarPanelBottomConstraint.constant = 0.0;
        [CPProcessManager animateWithDuration:0.3 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.supermanager dismissSubviewManager:self];
        }];
    }];
}

#pragma mark - CPInteractiveTransitioning implement

- (void)updateInteractiveTranstionByTranslation:(CGPoint)translation {
    self.searchBarPanelBottomConstraint.constant += translation.y;
    if (self.searchBarPanelBottomConstraint.constant > self.searchBarPanel.bounds.size.height) {
        self.searchBarPanelBottomConstraint.constant = self.searchBarPanel.bounds.size.height;
    }
}

- (void)finishInteractiveTranstion {
    if (self.searchBarPanelBottomConstraint.constant < self.searchBarPanel.bounds.size.height) {
        self.searchBarPanelBottomConstraint.constant = self.searchBarPanel.bounds.size.height;
    }
    [CPProcessManager animateWithDuration:0.3 animations:^{
        [self.searchBarPanel layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.searchBar becomeFirstResponder];
        
        [self.superview addSubview:self.resultCollectionViewPanel];
        [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.resultCollectionViewPanel alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
        [self.superview addConstraint:[CPConstraintHelper constraintWithView:self.resultCollectionViewPanel attribute:NSLayoutAttributeTop alignToView:self.searchBarPanel attribute:NSLayoutAttributeBottom]];
        
        self.resultCollectionViewPanel.alpha = 0.0;
        [CPProcessManager animateWithDuration:0.3 animations:^{
            self.resultCollectionViewPanel.alpha = 1.0;
        }];
    }];
}

- (void)cancelInteractiveTransition {
    self.searchBarPanelBottomConstraint.constant = 0.0;
    [CPProcessManager animateWithDuration:0.5 animations:^{
        [self.searchBarPanel layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.supermanager dismissSubviewManager:self];
    }];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CPMemoCell reuseIdentifier] forIndexPath:indexPath];
    cell.label.text = @"11111111";
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, 44.0);
}

#pragma mark - UISearchBarDelegate implement

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self unloadViewsWithAnimation];
}

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
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _searchBar;
}

- (UIView *)resultCollectionViewPanel {
    if (!_resultCollectionViewPanel) {
        _resultCollectionViewPanel = [[UIView alloc] init];
        _resultCollectionViewPanel.backgroundColor = [UIColor clearColor];
        _resultCollectionViewPanel.clipsToBounds = YES;
        _resultCollectionViewPanel.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImageView *background = [[UIImageView alloc] initWithImage:self.bluredBackgroundImage];
        background.translatesAutoresizingMaskIntoConstraints = NO;
        [_resultCollectionViewPanel addSubview:background];
        [_resultCollectionViewPanel addConstraints:[CPConstraintHelper constraintsWithView:background alignToView:_resultCollectionViewPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
    }
    return _resultCollectionViewPanel;
}

- (UICollectionView *)resultCollectionView {
    if (!_resultCollectionView) {
        _resultCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _resultCollectionView.dataSource = self;
        _resultCollectionView.delegate = self;
        _resultCollectionView.backgroundColor = [UIColor clearColor];
        _resultCollectionView.showsHorizontalScrollIndicator = NO;
        _resultCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_resultCollectionView registerClass:[CPMemoCell class] forCellWithReuseIdentifier:[CPMemoCell reuseIdentifier]];
    }
    return _resultCollectionView;
}

@end
