//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "UIImage+ImageEffects.h"

#import "CPAppearanceManager.h"
#import "CPRectLayout.h"
#import "CPPassEditorManager.h"
#import "CPSettingManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassContainerManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@property (strong, nonatomic) UIView *settingView;
@property (strong, nonatomic) NSLayoutConstraint *settingViewBottomLayout;
@property (strong, nonatomic) CPSettingManager *settingManager;
@property (nonatomic) CGPoint lastTranslation;

@property (strong, nonatomic) NSLayoutConstraint *snapshotTopLayout;

@property (strong, nonatomic) UIView *passEditorView;
@property (strong, nonatomic) CPPassEditorManager *passEditorManager;

@end

@implementation CPPassContainerManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
    
    [self.passCollectionView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)loadSettingView {
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

    [self.settingView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)unloadSettingView {
    [self.settingView removeFromSuperview];
    self.settingView = nil;
    self.settingViewBottomLayout = nil;
    self.settingManager = nil;
    self.snapshotTopLayout = nil;
}

- (void)moveSettingViewByTranslation:(CGPoint)translation {
    self.lastTranslation = translation;
    self.settingViewBottomLayout.constant += self.lastTranslation.y;
    self.snapshotTopLayout.constant -= self.lastTranslation.y;
}

- (void)animateSettingViewToEnd {
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

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (!self.settingView) {
            [self loadSettingView];
        }
        [self moveSettingViewByTranslation:[gesture translationInView:self.settingView]];
        [gesture setTranslation:CGPointZero inView:self.settingView];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self animateSettingViewToEnd];
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

- (void)unloadPassEditor {
    [self.passEditorManager unloadAnimated:YES];
    [self.passEditorView removeFromSuperview];
    self.passEditorManager = nil;
    self.passEditorView = nil;
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PassCollectionViewCell" forIndexPath:indexPath];
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIGraphicsBeginImageContextWithOptions(self.superview.bounds.size, NO, self.superview.window.screen.scale);
    [self.superview drawViewHierarchyInRect:self.superview.frame afterScreenUpdates:NO];
    UIImageView *passEditorBackgroundImageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    
    passEditorBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:passEditorBackgroundImageView];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:passEditorBackgroundImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:passEditorBackgroundImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:passEditorBackgroundImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:passEditorBackgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.superview addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
    [self.superview layoutIfNeeded];
    
    CGRect cellFrame = [collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGRect destFrame = self.superview.bounds;
    CGFloat xScale = destFrame.size.width / cellFrame.size.width;
    CGFloat yScale = destFrame.size.height / cellFrame.size.height;
    leftConstraint.constant = - cellFrame.origin.x * xScale - 1;
    rightConstraint.constant = (destFrame.size.width - cellFrame.origin.x - cellFrame.size.width) * xScale + 1;
    topConstraint.constant = - cellFrame.origin.y * yScale - 1;
    bottomConstraint.constant = (destFrame.size.height - cellFrame.origin.y - cellFrame.size.height) * yScale + 1;
    
    [CPAppearanceManager animateWithDuration:0.5 animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [passEditorBackgroundImageView removeFromSuperview];
        
        self.passEditorView = [[UIView alloc] init];
        self.passEditorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview addSubview:self.passEditorView];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passEditorView edgesAlignToView:self.superview]];
        
        self.passEditorManager = [[CPPassEditorManager alloc] initWithSupermanager:self andSuperview:self.passEditorView];
        self.passEditorManager.index = indexPath.row;
        [self.passEditorManager loadAnimated:YES];
    }];
    
}

#pragma mark - lazy init

- (UICollectionView *)passCollectionView {
    if (!_passCollectionView) {
        _passCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[CPRectLayout alloc] init]];
        _passCollectionView.dataSource = self;
        _passCollectionView.delegate = self;
        _passCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [_passCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PassCollectionViewCell"];
    }
    return _passCollectionView;
}

@end
