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
#import "CPSearchViewManager.h"

#import "CPEditingPassCellProcess.h"
#import "CPDraggingPassCellProcess.h"
#import "CPSearchProcess.h"

#import "CPRectLayout.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassContainerManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) CPSearchViewManager *searchViewManager;

@property (nonatomic) CGPoint panTranslation;

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

- (void)loadViewsWithAnimation {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [CPPassDataManager defaultManager].passwordsController.delegate = self;
    
    [self.superview addSubview:self.passCollectionView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.delegate = self;
    [self.passCollectionView addGestureRecognizer:longPressGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.passCollectionView addGestureRecognizer:panGesture];
}

- (void)loadPassEditorViewWithPassword:(CPPassword *)password andCellFrame:(CGRect)cellFrame {
    UIView *snapshotView = [self.superview snapshotViewAfterScreenUpdates:NO];
    snapshotView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.passEditorView = [[UIView alloc] init];
    self.passEditorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.passEditorView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passEditorView edgesAlignToView:self.superview]];
    
    self.passEditorManager = [[CPPassEditorManager alloc] initWithPassword:password backgroundSnapshotView:snapshotView originalCellFrame:cellFrame supermanager:self andSuperview:self.passEditorView];
    [self.passEditorManager loadViewsWithAnimation];
}

- (void)loadSearchView {
    self.searchView = [[UIView alloc] init];
    self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.searchView];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.searchView edgesAlignToView:self.superview]];
    
    self.searchViewManager = [[CPSearchViewManager alloc] initWithBluredBackgroundImage:[self createSnapshot] Supermanager:self andSuperview:self.searchView];
    [self.searchViewManager loadViewsWithAnimation];
}

- (void)dismissSubviewManager:(CPViewManager *)subviewManager {
    if (IS_IN_PROCESS(SEARCH_PROCESS)) {
        NSAssert(subviewManager == self.searchViewManager, @"");
        if (STOP_PROCESS(SEARCH_PROCESS)) {
            [self.searchView removeFromSuperview];
            self.searchView = nil;
            self.searchViewManager = nil;
            self.panTranslation = CGPointZero;
        }
    } else if (subviewManager == self.passEditorManager) {
        [self.passEditorView removeFromSuperview];
        self.passEditorView = nil;
        self.passEditorManager = nil;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        if (START_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self startDraggingPassCellAtPoint:[longPressGesture locationInView:longPressGesture.view]];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged) {
        self.panTranslation = [panGesture translationInView:panGesture.view];
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self dragPassCellByTranslation:self.panTranslation];
        } else if (IS_IN_PROCESS(SEARCH_PROCESS)) {
            [self.searchViewManager updateInteractiveTranstionByTranslation:self.panTranslation];
        } else {
            if (START_PROCESS(SEARCH_PROCESS)) {
                [self loadSearchView];
                [self.searchViewManager updateInteractiveTranstionByTranslation:self.panTranslation];
            }
        }
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_CELL_PROCESS)) {
            [self stopDraggingPassCell];
        } else if (IS_IN_PROCESS(SEARCH_PROCESS)) {
            if (self.panTranslation.y >= 0.0) {
                [self.searchViewManager finishInteractiveTranstion];
            } else {
                [self.searchViewManager cancelInteractiveTransition];
            }
        }
    }
}

- (UIImage *)createSnapshot {
    UIGraphicsBeginImageContextWithOptions(self.superview.bounds.size, NO, self.superview.window.screen.scale);
    [self.superview drawViewHierarchyInRect:self.superview.bounds afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
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

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.passCollectionView reloadData];
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
        CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:indexPath.row];
        [self loadPassEditorViewWithPassword:password andCellFrame:[collectionView cellForItemAtIndexPath:indexPath].frame];
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
