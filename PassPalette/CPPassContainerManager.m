//
//  CPPassContainerManager.m
//  PassPalette
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPAppearenceManager.h"
#import "CPUIKitHelper.h"
#import "CPPassEditorManager.h"
#import "CPProcessManager.h"
#import "CPSearchManager.h"
#import "CPSettingsManager.h"

#import "CPPassEdittingProcess.h"
#import "CPPassCellDraggingProcess.h"
#import "CPSearchingProcess.h"
#import "CPSettingsProcess.h"

#import "CPRectLayout.h"
#import "CPImageHelper.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassContainerManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@property (nonatomic) CGPoint panTranslation;

@property (strong, nonatomic) UIView *interactiveView;
@property (strong, nonatomic) CPInteractiveViewManager *interactiveViewManager;

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
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
    
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
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.passEditorView edgesAlignToView:self.superview]];
    
    self.passEditorManager = [[CPPassEditorManager alloc] initWithPassword:password backgroundSnapshotView:snapshotView originalCellFrame:cellFrame supermanager:self andSuperview:self.passEditorView];
    [self.passEditorManager loadViewsWithAnimation];
}

- (void)loadInteractiveView {
    self.interactiveView = [[UIView alloc] init];
    self.interactiveView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.interactiveView];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.interactiveView edgesAlignToView:self.superview]];

    UIImage *snapshot = [CPImageHelper bluredSnapshotForView:self.superview];
    if (IS_IN_PROCESS(SEARCHING_PROCESS)) {
        self.interactiveViewManager = [[CPSearchManager alloc] initWithBluredBackgroundImage:snapshot Supermanager:self andSuperview:self.interactiveView];
    } else if (IS_IN_PROCESS(SETTINGS_PROCESS)) {
        self.interactiveViewManager = [[CPSettingsManager alloc] initWithBluredBackgroundImage:snapshot Supermanager:self andSuperview:self.interactiveView];
    } else {
        NSAssert(NO, @"");
    }
    [self.interactiveViewManager loadViewsWithAnimation];
}

- (void)dismissSubviewManager:(CPViewManager *)subviewManager {
    if (IS_IN_PROCESS(SEARCHING_PROCESS) || IS_IN_PROCESS(SETTINGS_PROCESS)) {
        NSAssert(subviewManager == self.interactiveViewManager, @"");
        if (STOP_PROCESS(SEARCHING_PROCESS) || STOP_PROCESS(SETTINGS_PROCESS)) {
            [self.interactiveView removeFromSuperview];
            self.interactiveView = nil;
            self.interactiveViewManager = nil;
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
        if (START_PROCESS(PASS_CELL_DRAGGING_PROCESS)) {
            [self startDraggingPassCellAtPoint:[longPressGesture locationInView:longPressGesture.view]];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged) {
        self.panTranslation = [panGesture translationInView:panGesture.view];
        if (IS_IN_PROCESS(PASS_CELL_DRAGGING_PROCESS)) {
            [self dragPassCellByTranslation:self.panTranslation];
        } else if (IS_IN_PROCESS(SEARCHING_PROCESS) || IS_IN_PROCESS(SETTINGS_PROCESS)) {
            [self.interactiveViewManager updateInteractiveTranstionByTranslation:self.panTranslation];
        } else {
            if (self.panTranslation.y >= 0.0) {
                if (START_PROCESS(SEARCHING_PROCESS)) {
                    [self loadInteractiveView];
                    [self.interactiveViewManager updateInteractiveTranstionByTranslation:self.panTranslation];
                }
            } else {
                if (START_PROCESS(SETTINGS_PROCESS)) {
                    [self loadInteractiveView];
                    [self.interactiveViewManager updateInteractiveTranstionByTranslation:self.panTranslation];
                }
            }
        }
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(PASS_CELL_DRAGGING_PROCESS)) {
            [self stopDraggingPassCell];
        } else if (IS_IN_PROCESS(SEARCHING_PROCESS)) {
            if (self.panTranslation.y >= 0.0) {
                [self.interactiveViewManager finishInteractiveTranstion];
            } else {
                [self.interactiveViewManager cancelInteractiveTransition];
            }
        } else if (IS_IN_PROCESS(SETTINGS_PROCESS)) {
            if (self.panTranslation.y <= 0.0) {
                [self.interactiveViewManager finishInteractiveTranstion];
            } else {
                [self.interactiveViewManager cancelInteractiveTransition];
            }
        }
    }
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
            if (STOP_PROCESS(PASS_CELL_DRAGGING_PROCESS)) {
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
    cell.contentView.backgroundColor = [[CPAppearenceManager defaultManager].colorTable colorOfEntropy:password.entropy.floatValue];
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (START_PROCESS(PASS_EDITTING_PROCESS)) {
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
