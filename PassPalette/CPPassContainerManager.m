//
//  CPPassContainerManager.m
//  PassPalette
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "UIImage+ImageEffects.h"

#import "CPConstraintHelper.h"
#import "CPPassEditorManager.h"
#import "CPProcessManager.h"
#import "CPSettingsManager.h"

#import "CPEditingPassCellProcess.h"
#import "CPDraggingPassCellProcess.h"
#import "CPSettingsProcess.h"

#import "CPRectLayout.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassContainerManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@property (strong, nonatomic) UIView *settingView;
@property (strong, nonatomic) NSLayoutConstraint *settingViewBottomLayout;
@property (strong, nonatomic) CPSettingsManager *settingsManager;
@property (nonatomic) CGPoint lastTranslation;

@property (strong, nonatomic) NSLayoutConstraint *settingBackgroundTopLayoutConstraint;

@property (strong, nonatomic) UIView *snapshotView;
@property (strong, nonatomic) UIView *passEditorView;
@property (strong, nonatomic) CPPassEditorManager *passEditorManager;

@property (weak, nonatomic) UICollectionViewCell *draggingSourceCell;
@property (weak, nonatomic) UICollectionViewCell *draggingDestinationCell;
@property (strong, nonatomic) UIImageView *draggingImageView;
@property (strong, nonatomic) NSLayoutConstraint *draggingImageViewLeftLayoutConstraint;
@property (strong, nonatomic) NSLayoutConstraint *draggingImageViewTopLayoutConstraint;
@property (strong, nonatomic) UIImageView *destinationImageView;
@property (strong, nonatomic) NSLayoutConstraint *destinationImageViewLeftLayoutConstraint;
@property (strong, nonatomic) NSLayoutConstraint *destinationImageViewTopLayoutConstraint;

@end

@implementation CPPassContainerManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passCollectionView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.delegate = self;
    [self.passCollectionView addGestureRecognizer:longPressGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.passCollectionView addGestureRecognizer:panGesture];
}

- (void)loadSettingView {
    self.settingView = [[UIView alloc] init];
    self.settingView.clipsToBounds = YES;
    self.settingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.settingView];
    
    self.settingViewBottomLayout = [NSLayoutConstraint constraintWithItem:self.settingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self.superview addConstraint:self.settingViewBottomLayout];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.settingView alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeHeight, ATTR_END]];
    
    UIImageView *background = [self createSnapshot];
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self.settingView addSubview:background];
    
    self.settingBackgroundTopLayoutConstraint = [NSLayoutConstraint constraintWithItem:background attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.settingView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    [self.settingView addConstraint:self.settingBackgroundTopLayoutConstraint];
    [self.settingView addConstraints:[CPConstraintHelper constraintsWithView:background alignToView:self.settingView attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeHeight, ATTR_END]];
    
    self.settingsManager = [[CPSettingsManager alloc] initWithSupermanager:self andSuperview:self.settingView];
    [self.settingsManager loadAnimated:YES];

    [self.settingView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
}

- (void)unloadSettingView {
    if (STOP_PROCESS(SETTINGS_PROCESS)) {
        [self.settingsManager unloadAnimated:YES];
        [self.settingView removeFromSuperview];
        self.settingView = nil;
        self.settingViewBottomLayout = nil;
        self.settingsManager = nil;
        self.settingBackgroundTopLayoutConstraint = nil;
    }
}

- (void)moveSettingViewByTranslation:(CGPoint)translation {
    self.lastTranslation = translation;
    self.settingViewBottomLayout.constant += self.lastTranslation.y;
    self.settingBackgroundTopLayoutConstraint.constant -= self.lastTranslation.y;
}

- (void)animateSettingViewToEnd {
    if (self.lastTranslation.y >= 0.0) {
        self.settingViewBottomLayout.constant = self.superview.bounds.size.height;
        self.settingBackgroundTopLayoutConstraint.constant = -self.superview.bounds.size.height;
    } else {
        self.settingViewBottomLayout.constant = 0;
        self.settingBackgroundTopLayoutConstraint.constant = 0;
    }
    
    [CPProcessManager animateWithDuration:0.5 animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.lastTranslation.y < 0) {
            [self unloadSettingView];
        }
    }];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (START_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self startDraggingPassCellAtPoint:[longPressGesture locationInView:longPressGesture.view]];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint tranlation = [panGesture translationInView:panGesture.view];
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self dragPassCellByTranslation:tranlation];
        } else if (IS_IN_PROCESS(SETTINGS_PROCESS)) {
            [self moveSettingViewByTranslation:tranlation];
        } else {
            if (START_PROCESS(SETTINGS_PROCESS)) {
                if (!self.settingView) {
                    [self loadSettingView];
                }
            }
        }
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self stopDraggingPassCell];
        } else if (IS_IN_PROCESS(SETTINGS_PROCESS)) {
            [self animateSettingViewToEnd];
        }
    }
}

- (UIImageView *)createSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.superview.bounds.size, NO, self.superview.window.screen.scale);
    [self.superview drawViewHierarchyInRect:self.superview.bounds afterScreenUpdates:NO];
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

- (void)transitToPassEditorViewFromItemAtIndexPath:(NSIndexPath *)indexPath {
    // create the snapshot view
    self.snapshotView = [self.superview snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.snapshotView];
    
    // create the pass editor view
    self.passEditorView = [[UIView alloc] init];
    self.passEditorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.passEditorView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passEditorView edgesAlignToView:self.superview]];
    
    // create pass editor manager
    self.passEditorManager = [[CPPassEditorManager alloc] initWithPassword:[[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:indexPath.row] supermanager:self andSuperview:self.passEditorView];
    [self.passEditorManager loadAnimated:YES];
    [self.superview layoutIfNeeded];

    // create pass editor snapshot
    UIView *passEditorSnapshot = [self.passEditorView snapshotViewAfterScreenUpdates:YES];
    passEditorSnapshot.alpha = 0.0;
    passEditorSnapshot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:passEditorSnapshot];
    // hide pass editor view
    self.passEditorView.hidden = YES;
    
    // calculate layout constraint constants for the selected cell
    CGRect cellFrame = [self.passCollectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    CGRect destFrame = self.superview.bounds;
    CGFloat xScale = destFrame.size.width / cellFrame.size.width;
    CGFloat yScale = destFrame.size.height / cellFrame.size.height;
    
    // add constraints for the snapshot view
    NSLayoutConstraint *leftSnapshotConstraint = [CPConstraintHelper constraintWithView:self.snapshotView alignToView:self.superview attribute:NSLayoutAttributeLeft constant:0.0];
    NSLayoutConstraint *rightSnapshotConstraint = [CPConstraintHelper constraintWithView:self.snapshotView alignToView:self.superview attribute:NSLayoutAttributeRight constant:0.0];
    NSLayoutConstraint *topSnapshotConstraint = [CPConstraintHelper constraintWithView:self.snapshotView alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    NSLayoutConstraint *bottomSnapshotConstraint = [CPConstraintHelper constraintWithView:self.snapshotView alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
    [self.superview addConstraints:@[leftSnapshotConstraint, rightSnapshotConstraint, topSnapshotConstraint, bottomSnapshotConstraint]];

    // add constraints for the pass editor snapshot view
    NSLayoutConstraint *leftPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeLeft constant:cellFrame.origin.x];
    NSLayoutConstraint *rightPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeRight constant:-(destFrame.size.width - cellFrame.origin.x - cellFrame.size.width)];
    NSLayoutConstraint *topPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeTop constant:cellFrame.origin.y];
    NSLayoutConstraint *bottomPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeBottom constant:-(destFrame.size.height - cellFrame.origin.y - cellFrame.size.height)];
    [self.superview addConstraints:@[leftPassEditorSnapshotConstraint, rightPassEditorSnapshotConstraint, topPassEditorSnapshotConstraint, bottomPassEditorSnapshotConstraint]];
    [self.superview layoutIfNeeded];
    
    // enlarge snapshot view
    leftSnapshotConstraint.constant = -cellFrame.origin.x * xScale - 1;
    rightSnapshotConstraint.constant = (destFrame.size.width - cellFrame.origin.x - cellFrame.size.width) * xScale + 1;
    topSnapshotConstraint.constant = -cellFrame.origin.y * yScale - 1;
    bottomSnapshotConstraint.constant = (destFrame.size.height - cellFrame.origin.y - cellFrame.size.height) * yScale + 1;
    
    leftPassEditorSnapshotConstraint.constant = 0.0;
    rightPassEditorSnapshotConstraint.constant = 0.0;
    topPassEditorSnapshotConstraint.constant = 0.0;
    bottomPassEditorSnapshotConstraint.constant = 0.0;
    
    [CPProcessManager animateWithDuration:0.4 animations:^{
        passEditorSnapshot.alpha = 1.0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [passEditorSnapshot removeFromSuperview];
        self.passEditorView.hidden = NO;
    }];
}

#pragma mark - dragging pass cell

- (void)startDraggingPassCellAtPoint:(CGPoint)point {
    self.draggingSourceCell = [self passCellAtPoint:point];
    
    UIGraphicsBeginImageContextWithOptions(self.draggingSourceCell.bounds.size, NO, self.superview.window.screen.scale);
    [self.draggingSourceCell drawViewHierarchyInRect:self.draggingSourceCell.bounds afterScreenUpdates:NO];
    self.draggingImageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    self.draggingImageView.alpha = 0.8;
    self.draggingImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.draggingImageView.layer.shadowOffset = CGSizeMake(5.0, 5.0);
    self.draggingImageView.layer.shadowOpacity = 0.8;
    self.draggingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addSubview:self.draggingImageView];
    self.draggingImageViewLeftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.draggingImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.draggingSourceCell.frame.origin.x];
    [self.superview addConstraint:self.draggingImageViewLeftLayoutConstraint];
    self.draggingImageViewTopLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.draggingImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.draggingSourceCell.frame.origin.y];
    [self.superview addConstraint:self.draggingImageViewTopLayoutConstraint];
    
    self.draggingSourceCell.hidden = YES;
}

- (void)dragPassCellByTranslation:(CGPoint)translation {
    self.draggingImageViewLeftLayoutConstraint.constant += translation.x;
    self.draggingImageViewTopLayoutConstraint.constant += translation.y;
    UICollectionViewCell *draggingDestinationCell = [self passCellAtPoint:self.draggingImageView.center];
    if (draggingDestinationCell == self.draggingSourceCell) {
        draggingDestinationCell = nil;
    }
    if (self.draggingDestinationCell != draggingDestinationCell) {
        self.draggingDestinationCell.alpha = 1.0;
        self.draggingDestinationCell = draggingDestinationCell;
        self.draggingDestinationCell.alpha = 0.8;
    }
}

- (void)stopDraggingPassCell {
    if (self.draggingDestinationCell) {
        UIGraphicsBeginImageContextWithOptions(self.draggingDestinationCell.bounds.size, NO, self.superview.window.screen.scale);
        [self.draggingDestinationCell drawViewHierarchyInRect:self.draggingDestinationCell.bounds afterScreenUpdates:NO];
        self.destinationImageView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
        UIGraphicsEndImageContext();
        self.destinationImageView.alpha = 0.8;
        self.destinationImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.destinationImageView.layer.shadowOffset = CGSizeMake(5.0, 5.0);
        self.destinationImageView.layer.shadowOpacity = 0.8;
        self.destinationImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.superview addSubview:self.destinationImageView];
        self.destinationImageViewLeftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.destinationImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.draggingDestinationCell.frame.origin.x];
        [self.superview addConstraint:self.destinationImageViewLeftLayoutConstraint];
        self.destinationImageViewTopLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.destinationImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.draggingDestinationCell.frame.origin.y];
        [self.superview addConstraint:self.destinationImageViewTopLayoutConstraint];

        self.draggingDestinationCell.hidden = YES;
        
        [self.superview layoutIfNeeded];
        
        self.draggingImageViewLeftLayoutConstraint.constant = self.draggingDestinationCell.frame.origin.x;
        self.draggingImageViewTopLayoutConstraint.constant = self.draggingDestinationCell.frame.origin.y;
        self.destinationImageViewLeftLayoutConstraint.constant = self.draggingSourceCell.frame.origin.x;
        self.destinationImageViewTopLayoutConstraint.constant = self.draggingSourceCell.frame.origin.y;
        
        [CPProcessManager animateWithDuration:0.5 animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (STOP_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
                [self.draggingImageView removeFromSuperview];
                [self.destinationImageView removeFromSuperview];
                self.draggingImageView = nil;
                self.destinationImageView = nil;
                self.draggingImageViewLeftLayoutConstraint = nil;
                self.draggingImageViewTopLayoutConstraint = nil;
                self.destinationImageViewLeftLayoutConstraint = nil;
                self.destinationImageViewTopLayoutConstraint = nil;
                self.draggingSourceCell.hidden = NO;
                self.draggingDestinationCell.hidden = NO;
            }
        }];
    }
    
}

#pragma mark - utility

- (UICollectionViewCell *)passCellAtPoint:(CGPoint)point {
    return [self.passCollectionView cellForItemAtIndexPath:[self.passCollectionView indexPathForItemAtPoint:point]];
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
    if (START_PROCESS(EDITING_PASS_CELL_PROCESS)) {
        [self transitToPassEditorViewFromItemAtIndexPath:indexPath];
    }
}

#pragma mark - UIGestureRecognizerDelegate implement

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - lazy init

- (UICollectionView *)passCollectionView {
    if (!_passCollectionView) {
        _passCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[CPRectLayout alloc] init]];
        _passCollectionView.dataSource = self;
        _passCollectionView.delegate = self;
        _passCollectionView.scrollEnabled = NO;
        _passCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [_passCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"PassCollectionViewCell"];
    }
    return _passCollectionView;
}

@end
