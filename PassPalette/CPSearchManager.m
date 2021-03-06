//
//  CPSearchViewManager.m
//  PassPalette
//
//  Created by wangyw on 1/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSearchManager.h"

#import "CPAppearenceManager.h"
#import "CPMainViewController.h"
#import "CPMemo.h"
#import "CPMemoCell.h"
#import "CPPassContainerManager.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"
#import "CPProcessManager.h"
#import "CPUIKitHelper.h"

@interface CPSearchManager ()

@property (strong, nonatomic) UIView *searchBarPanel;
@property (strong, nonatomic) NSLayoutConstraint *searchBarPanelBottomConstraint;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UIView *resultCollectionViewPanel;
@property (strong, nonatomic) UICollectionView *resultCollectionView;
@property (strong, nonatomic) NSLayoutConstraint *resultCollectionViewBottomConstraint;

@property (strong, nonatomic) NSArray *resultMemos;

@end

@implementation CPSearchManager

- (void)loadViewsWithAnimation {
    [self.superview addSubview:self.searchBarPanel];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.searchBarPanel alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:self.searchBarPanelBottomConstraint];
    [self addBackgroundImageIntoView:self.searchBarPanel];
    
    [self.searchBarPanel addSubview:self.searchBar];
    [self.searchBarPanel addConstraints:[CPUIKitHelper constraintsWithView:self.searchBar alignToView:self.searchBarPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.searchBarPanel addConstraint:[CPUIKitHelper constraintWithView:self.searchBar alignToView:self.searchBarPanel attribute:NSLayoutAttributeTop constant:[CPMainViewController mainViewController].topLayoutGuide.length]];
    [self.searchBarPanel addConstraint:[CPUIKitHelper constraintWithView:self.searchBar alignToView:self.searchBarPanel attribute:NSLayoutAttributeBottom]];
}

- (void)unloadViewsWithAnimation {
    [self.searchBar resignFirstResponder];
    [CPProcessManager animateWithDuration:0.3 animations:^{
        self.resultCollectionViewPanel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.searchBarPanelBottomConstraint.constant = 0.0;
        [CPProcessManager animateWithDuration:0.3 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.supermanager dismissSubviewManager:self];
        }];
    }];
}

- (void)loadResultCollectionViewPanelWithAnimation {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.searchBar becomeFirstResponder];
    
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:@""];
    
    [self.superview addSubview:self.resultCollectionViewPanel];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.resultCollectionViewPanel alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
    [self.superview addConstraint:[CPUIKitHelper constraintWithView:self.resultCollectionViewPanel attribute:NSLayoutAttributeTop alignToView:self.searchBarPanel attribute:NSLayoutAttributeBottom constant:1.0]];
    
    [self addBackgroundImageIntoView:self.resultCollectionViewPanel];
    [self.resultCollectionViewPanel addSubview:self.resultCollectionView];
    [self.resultCollectionViewPanel addConstraints:[CPUIKitHelper constraintsWithView:self.resultCollectionView alignToView:self.resultCollectionViewPanel attributes:NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    self.resultCollectionViewBottomConstraint = [CPUIKitHelper constraintWithView:self.resultCollectionView alignToView:self.resultCollectionViewPanel attribute:NSLayoutAttributeBottom];
    [self.resultCollectionViewPanel addConstraint:self.resultCollectionViewBottomConstraint];
    
    self.resultCollectionViewPanel.alpha = 0.0;
    [CPProcessManager animateWithDuration:0.3 animations:^{
        self.resultCollectionViewPanel.alpha = 1.0;
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
        [self loadResultCollectionViewPanelWithAnimation];
    }];
}

- (void)cancelInteractiveTransition {
    self.searchBarPanelBottomConstraint.constant = 0.0;
    [CPProcessManager animateWithDuration:0.3 animations:^{
        [self.searchBarPanel layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.supermanager dismissSubviewManager:self];
    }];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultMemos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CPMemoCell reuseIdentifier] forIndexPath:indexPath];
    cell.showBackgroundColor = YES;
    CPMemo *memo = [self.resultMemos objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [[CPAppearenceManager defaultManager].colorTable colorOfPassStrength:memo.password.strength.floatValue];
    cell.label.text = memo.text;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    [CPUIKitHelper enableControlsInView:self.searchBar];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, 44.0);
}

#pragma mark - UISearchBarDelegate implement

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.resultMemos = [[CPPassDataManager defaultManager] memosContainText:searchBar.text];
    [self.resultCollectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [CPUIKitHelper enableControlsInView:searchBar];
}

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
    }
    return _searchBarPanel;
}

- (NSLayoutConstraint *)searchBarPanelBottomConstraint {
    if (!_searchBarPanelBottomConstraint) {
        _searchBarPanelBottomConstraint = [CPUIKitHelper constraintWithView:self.searchBarPanel attribute:NSLayoutAttributeBottom alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    }
    return _searchBarPanelBottomConstraint;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.barTintColor = [UIColor clearColor];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"Search: memos";
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
