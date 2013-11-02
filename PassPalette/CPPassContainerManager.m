//
//  CPPassContainerManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerManager.h"

#import "CPPassPaletteConfig.h"

#import "CPAppearanceManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPMainViewController.h"
// #import "CPPassEditManager.h"

#import "CPProcessManager.h"
// #import "CPDraggingPassViewProcess.h"

static float g_positioningArray[PASSWORD_MAX_COUNT * 2] = {-1.0};

@interface CPPassContainerManager ()

@property (strong, nonatomic) NSMutableArray *passwordViews;
@property (strong, nonatomic) NSMutableArray *passwordConstraints;

// @property (strong, nonatomic) CPPasswordRangeView *passwordContainer;

@property (strong, nonatomic) UIView *passEditView;
// @property (strong, nonatomic) CPPassEditManager *passEditManager;

// @property (strong, nonatomic) CPPasswordView *dragView;
@property (strong, nonatomic) NSLayoutConstraint *dragViewCenterXConstraint;
@property (strong, nonatomic) NSLayoutConstraint *dragViewCenterYConstraint;
// @property (weak, nonatomic) CPPasswordView *dragSourceView;
// @property (weak, nonatomic) CPPasswordView *dragDestinationView;

@end

@implementation CPPassContainerManager

+ (CGPoint)positionForPasswordAtIndex:(int)index {
    if (g_positioningArray[0] == -1.0) {
        [CPPassContainerManager refreshPositions];
    }
    return CGPointMake(g_positioningArray[index * 2], g_positioningArray[index * 2 + 1]);
}

+ (void)refreshPositions {
    [CPPassContainerManager refreshPositionsWithOrientation:currentOrientation()];
}

+ (void)refreshPositionsWithOrientation:(UIInterfaceOrientation)orientation {
    float r = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation), m = PASSWORD_HORIZON_DISTANCE_MULTIPLIER;
    float positioningArray[] = {
        0.0, 0.0,
        0.0, -2 * r,
        -m * r, -r,
        -m * r, r,
        0.0, 2 * r,
        m * r, r,
        m * r, -r
    };
    NSAssert(sizeof(g_positioningArray) == sizeof(positioningArray), @"positioningArray and g_positioningArray should be the same size.");
    memcpy(g_positioningArray, positioningArray, sizeof(g_positioningArray));
}

- (id)initWithSupermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        /*[CPPassDataManager defaultManager].passwordsController.delegate = self;
        
        self.superview.backgroundColor = [UIColor blackColor];
        
        [CPMainViewController startDeviceOrientationWillChangeNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:CPDeviceOrientationWillChangeNotification object:nil];
        
        [self.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longPress.delegate = self;
        [self.superview addGestureRecognizer:longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self.superview addGestureRecognizer:pan];*/
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CPDeviceOrientationWillChangeNotification object:nil];
    [CPMainViewController stopDeviceOrientationWillChangeNotifier];
}

- (void)loadAnimated:(BOOL)animated {
/*    [self.superview addSubview:self.passwordContainer];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordContainer centerAlignToView:self.superview]];
    
    float radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
    for (int i = 0; i < PASSWORD_MAX_COUNT; i++) {
        CPPasswordView *passwordView = [[CPPasswordView alloc] initWithIndex:i andRadius:radius];
        [self.passwordContainer addSubview:passwordView];
        [self.passwordViews addObject:passwordView];
    }
    [self refreshConstraints];*/
}

/*- (void)refreshConstraints {
    if (_passwordConstraints) {
        [self.passwordContainer removeConstraints:_passwordConstraints];
        _passwordConstraints = nil;
    }
    
    for (int i = 0; i < PASSWORD_MAX_COUNT; i++) {
        CPPasswordView *passwordView = [self.passwordViews objectAtIndex:i];
        CGPoint position = [CPPassContainerManager positionForPasswordAtIndex:i];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.passwordContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:position.x]];
        [self.passwordConstraints addObject:[NSLayoutConstraint constraintWithItem:passwordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.passwordContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:position.y]];
    }
    [self.passwordContainer addConstraints:self.passwordConstraints];
}*/

/*- (void)refreshRadiusWithOrientation:(UIInterfaceOrientation)orientation {
    float radius = PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) * PASSWORD_SIZE_MULTIPLIER;
    for (CPPasswordView *passwordView in self.passwordViews) {
        passwordView.radius = radius;
    }
}*/

/*- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation orientation = ((NSNumber *)notification.object).integerValue;
    [CPPassContainerManager refreshPositionsWithOrientation:orientation];
    [self refreshConstraints];
    [self refreshRadiusWithOrientation:orientation];
}

- (CGPoint)passwordContainerRelativeLocation:(UIGestureRecognizer *)gesture {
    return [self.passwordContainer convertPoint:[gesture locationInView:gesture.view] fromView:gesture.view];
}*/

// 'location' is relative to self.passwordContainer
/*- (CPPasswordView *)passwordViewAtLocation:(CGPoint)location {
    CPPasswordView *foundPasswordView = nil;
    for (CPPasswordView *passwordView in self.passwordViews) {
        if ([passwordView containsPoint:location]) {
            foundPasswordView = passwordView;
            break;
        }
    }
    return foundPasswordView;
}*/

// 'location' is relative to self.passwordContainer
/*- (BOOL)isLocationInRange:(CGPoint)location {
    return isPointInCircle(ownCoordinateViewCenter(self.passwordContainer), self.passwordContainer.frame.size.width / 2, location);
}

- (void)startDragPasswordView {
    self.passwordContainer.rangeVisibility = YES;
    
    self.dragView = [[CPPasswordView alloc] initWithIndex:self.dragSourceView.index andRadius:PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER];
    [self.passwordContainer addSubview:self.dragView];
    
    self.dragViewCenterXConstraint = [CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragSourceView attribute:NSLayoutAttributeCenterX];
    [self.passwordContainer addConstraint:self.dragViewCenterXConstraint];
    self.dragViewCenterYConstraint = [CPAppearanceManager constraintWithView:self.dragView alignToView:self.dragSourceView attribute:NSLayoutAttributeCenterY];
    [self.passwordContainer addConstraint:self.dragViewCenterYConstraint];
    
    self.dragSourceView.hidden = YES;
}*/

// 'location' is relative to self.passwordContainer
/*- (void)dragPasswordViewByTranslation:(CGPoint)translation toLocation:(CGPoint)location {
    self.dragViewCenterXConstraint.constant += translation.x;
    self.dragViewCenterYConstraint.constant += translation.y;
    [self.passwordContainer layoutIfNeeded];
    
    if ([self isLocationInRange:location]) {
        self.superview.backgroundColor = [UIColor blackColor];
        
        CPPasswordView *newDestinationView = [self passwordViewAtLocation:location];
        if (newDestinationView != self.dragSourceView && newDestinationView != self.dragDestinationView) {
            if (self.dragDestinationView) {
                if (self.dragDestinationView.password.isUsed.boolValue) {
                    self.dragDestinationView.radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
                } else {
                    self.dragDestinationView.isShining = NO;
                }
            }
            if (newDestinationView) {
                if (newDestinationView.password.isUsed.boolValue) {
                    newDestinationView.radius = PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER;
                } else {
                    newDestinationView.isShining = YES;
                }
            }
            
            self.dragDestinationView = newDestinationView;
        }
    } else {
        self.superview.backgroundColor = [UIColor redColor];
    }
}*/

// 'location' is relative to self.passwordContainer
/*- (void)stopDragPasswordViewAtLocation:(CGPoint)location {
    if ([self isLocationInRange:location]) {
        if (self.dragDestinationView) {
            if (self.dragDestinationView.password.isUsed.boolValue) {
                self.dragDestinationView.radius = PASSWORD_RADIUS * PASSWORD_SIZE_MULTIPLIER;
                self.dragDestinationView.hidden = YES;
                
                CPPasswordView *destinationMoveView = [[CPPasswordView alloc] initWithIndex:self.dragDestinationView.index andRadius:PASSWORD_RADIUS * PASSWORD_DRAG_SIZE_MULTIPLIER];
                [self.passwordContainer addSubview:destinationMoveView];
                
                NSArray *destinationMoveViewCenterConstraints = [CPAppearanceManager constraintsWithView:destinationMoveView centerAlignToView:self.dragDestinationView];
                [self.passwordContainer addConstraints:destinationMoveViewCenterConstraints];
                
                [self.passwordContainer bringSubviewToFront:self.dragView];
                [self.passwordContainer sendSubviewToBack:destinationMoveView];
                [self.passwordContainer layoutIfNeeded];
                
                [self.passwordContainer removeConstraint:self.dragViewCenterXConstraint];
                [self.passwordContainer removeConstraint:self.dragViewCenterYConstraint];
                [self.passwordContainer removeConstraints:destinationMoveViewCenterConstraints];
                
                [self.passwordContainer addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragDestinationView]];
                [self.passwordContainer addConstraints:[CPAppearanceManager constraintsWithView:destinationMoveView centerAlignToView:self.dragSourceView]];
                
                [CPAppearanceManager animateWithDuration:0.5 animations:^{
                    [self.passwordContainer layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceView.index andIndex2:self.dragDestinationView.index];
                    
                    self.dragSourceView.hidden = NO;
                    self.dragDestinationView.hidden = NO;
                    
                    [destinationMoveView removeFromSuperview];
                    
                    [self removeDragViews];
                }];
            } else {
                [self.passwordContainer removeConstraint:self.dragViewCenterXConstraint];
                [self.passwordContainer removeConstraint:self.dragViewCenterYConstraint];
                
                [self.passwordContainer addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragDestinationView]];
                
                self.dragSourceView.used = NO;
                self.dragSourceView.hidden = NO;
                self.dragSourceView.alpha = 0.0;
                
                [CPAppearanceManager animateWithDuration:0.5 animations:^{
                    self.dragSourceView.alpha = 1.0;
                    self.dragDestinationView.alpha = 0.0;
                    
                    [self.passwordContainer layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [[CPPassDataManager defaultManager] exchangePasswordBetweenIndex1:self.dragSourceView.index andIndex2:self.dragDestinationView.index];
                    
                    self.dragDestinationView.alpha = 1.0;
                    self.dragDestinationView.isShining = NO;
                    
                    [self removeDragViews];
                }];
            }
        } else {
            [self.passwordContainer removeConstraint:self.dragViewCenterXConstraint];
            [self.passwordContainer removeConstraint:self.dragViewCenterYConstraint];
            
            [self.passwordContainer addConstraints:[CPAppearanceManager constraintsWithView:self.dragView centerAlignToView:self.dragSourceView]];
            
            [CPAppearanceManager animateWithDuration:0.5 animations:^{
                [self.passwordContainer layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.dragSourceView.hidden = NO;
                
                [self removeDragViews];
            }];
        }
    } else {
        [self.passwordContainer removeConstraint:self.dragViewCenterYConstraint];
        
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.dragView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        self.dragSourceView.used = NO;
        self.dragSourceView.hidden = NO;
        self.dragSourceView.alpha = 0.0;
        
        [CPAppearanceManager animateWithDuration:0.5 animations:^{
            self.superview.backgroundColor = [UIColor blackColor];
            
            [self.superview layoutIfNeeded];
            
            self.dragView.alpha = 0.5;
            self.dragSourceView.alpha = 1.0;
        } completion:^(BOOL finished) {
            NSAssert([[CPPassDataManager defaultManager] canRemovePasswordAtIndex:self.dragSourceView.index], @"Unused password dragged and removed!");
            
            [[CPPassDataManager defaultManager] removePasswordAtIndex:self.dragSourceView.index];
            [self removeDragViews];
        }];
    }
}

- (void)removeDragViews {
    [self.dragView removeFromSuperview];
    
    self.passwordContainer.rangeVisibility = NO;
    
    self.dragView = nil;
    self.dragViewCenterXConstraint = nil;
    self.dragViewCenterYConstraint = nil;
    self.dragSourceView = nil;
    self.dragDestinationView = nil;
}

- (void)handleTapGesture:(UILongPressGestureRecognizer *)gesture {
    CPPasswordView * passwordView = [self passwordViewAtLocation:[gesture locationInView:gesture.view]];
    if (passwordView) {
        [self.superview addSubview:self.passEditView];
        [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passEditView edgesAlignToView:self.superview]];
        self.passEditManager = [[CPPassEditManager alloc] initWithSupermanager:self superview:self.passEditView andPassword:passwordView.password];
        [self.passEditManager loadAnimated:YES];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragSourceView = [self passwordViewAtLocation:[self passwordContainerRelativeLocation:gesture]];
        if (self.dragSourceView && self.dragSourceView.password.isUsed.boolValue) {
            [CPProcessManager startProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self startDragPasswordView];
            }];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self stopDragPasswordViewAtLocation:[self passwordContainerRelativeLocation:gesture]];
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [self dragPasswordViewByTranslation:[gesture translationInView:gesture.view] toLocation:[self passwordContainerRelativeLocation:gesture]];
            [gesture setTranslation:CGPointZero inView:gesture.view];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        if (IS_IN_PROCESS(DRAGGING_PASS_VIEW_PROCESS)) {
            [CPProcessManager stopProcess:DRAGGING_PASS_VIEW_PROCESS withPreparation:^{
                [self stopDragPasswordViewAtLocation:[self passwordContainerRelativeLocation:gesture]];
            }];
        }
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

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            [(CPPasswordView *)[self.passwordViews objectAtIndex:indexPath.row] setNeedsDisplay];
            break;
        case NSFetchedResultsChangeMove:
            [(CPPasswordView *)[self.passwordViews objectAtIndex:indexPath.row] setNeedsDisplay];
            [(CPPasswordView *)[self.passwordViews objectAtIndex:newIndexPath.row] setNeedsDisplay];
            break;
        default:
            NSAssert(NO, @"Unknowed change reported by NSFetchResultsController!");
            break;
    }
}

#pragma mark - lazy init

- (NSMutableArray *)passwordViews {
    if (!_passwordViews) {
        _passwordViews = [[NSMutableArray alloc] initWithCapacity:PASSWORD_MAX_COUNT];
    }
    return _passwordViews;
}

- (NSMutableArray *)passwordConstraints {
    if (!_passwordConstraints) {
        _passwordConstraints = [[NSMutableArray alloc] initWithCapacity:PASSWORD_MAX_COUNT * 2];
    }
    return _passwordConstraints;
}*/

/*- (CPPasswordRangeView *)passwordContainer {
    if (!_passwordContainer) {
        _passwordContainer = [[CPPasswordRangeView alloc] init];
    }
    return _passwordContainer;
}*/

- (UIView *)passEditView {
    if (!_passEditView) {
        _passEditView = [[UIView alloc] init];
        _passEditView.backgroundColor = [UIColor grayColor];
        _passEditView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passEditView;
}

@end
