//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPAppearanceManager.h"
#import "CPRectLayout.h"
#import "CPSettingManager.h"

#import "UIImage+ImageEffects.h"

@interface CPPassContainerManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@property (strong, nonatomic) UIView *settingView;
@property (strong, nonatomic) NSLayoutConstraint *settingViewBottomLayout;
@property (strong, nonatomic) CPSettingManager *settingManager;
@property (nonatomic) CGPoint lastTranslation;

@property (strong, nonatomic) NSLayoutConstraint *snapshotTopLayout;

@end

@implementation CPPassContainerManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.passCollectionView addGestureRecognizer:pan];
}

- (void)loadSettingView {
    NSAssert(!self.settingView, @"");
    NSAssert(!self.settingViewBottomLayout, @"");
    NSAssert(!self.settingManager, @"");
    NSAssert(!self.snapshotTopLayout, @"");
    
    self.settingView = [[UIView alloc] init];
    self.settingView.clipsToBounds = YES;
    self.settingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.settingView];
    
    self.settingViewBottomLayout = [NSLayoutConstraint constraintWithItem:self.settingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.superview addConstraint:self.settingViewBottomLayout];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.settingView alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeHeight, ATTR_END]];
    
    UIImageView *snapshot = [self createSnapshot];
    snapshot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.settingView addSubview:snapshot];
    
    self.snapshotTopLayout = [NSLayoutConstraint constraintWithItem:snapshot attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.settingView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.settingView addConstraint:self.snapshotTopLayout];
    [self.settingView addConstraints:[CPAppearanceManager constraintsWithView:snapshot alignToView:self.settingView attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeHeight, ATTR_END]];
    
    self.settingManager = [[CPSettingManager alloc] initWithSupermanager:self andSuperview:self.settingView];
    [self.settingManager loadAnimated:YES];
}

- (void)unloadSettingView {
    NSAssert(self.settingView, @"");
    NSAssert(self.settingViewBottomLayout, @"");
    NSAssert(self.settingManager, @"");
    NSAssert(self.snapshotTopLayout, @"");

    [self.settingView removeFromSuperview];
    self.settingView = nil;
    self.settingViewBottomLayout = nil;
    self.settingManager = nil;
    self.snapshotTopLayout = nil;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {

        [self loadSettingView];
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        self.lastTranslation = [gesture translationInView:self.settingView];
        self.settingViewBottomLayout.constant += self.lastTranslation.y;
        self.snapshotTopLayout.constant -= self.lastTranslation.y;
        [gesture setTranslation:CGPointZero inView:self.settingView];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {

        if (self.lastTranslation.y >= 0.0) {
            self.settingViewBottomLayout.constant = self.superview.bounds.size.height;
            self.snapshotTopLayout.constant = -self.superview.bounds.size.height;
        } else {
            self.settingViewBottomLayout.constant = 0;
            self.snapshotTopLayout.constant = 0;
        }
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.lastTranslation.y < 0) {
                [self unloadSettingView];
            }
        }];
        
    }
}

- (UIImageView *)createSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.superview.bounds.size, NO, self.superview.window.screen.scale);
    [self.superview drawViewHierarchyInRect:self.superview.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:blurredSnapshotImage];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHue:0.1 * indexPath.row saturation:1.0 brightness:1.0 alpha:1.0];
    return cell;
}

#pragma mark - lazy init

- (UICollectionView *)passCollectionView {
    if (!_passCollectionView) {
        _passCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[CPRectLayout alloc] init]];
        _passCollectionView.dataSource = self;
        _passCollectionView.delegate = self;
        _passCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [_passCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CELL"];
    }
    return _passCollectionView;
}

@end
