//
//  CPPassContainerViewController.m
//  PassPalette
//
//  Created by wangyw on 12/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerViewController.h"

#import "CPPanGestureTransition.h"
#import "CPPassEditorViewController.h"
#import "CPPassDataManager.h"
#import "CPPassEditorTransition.h"
#import "CPPassword.h"
#import "CPSearchViewController.h"

@interface CPPassContainerViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *passCollectionView;

@property (nonatomic) NSUInteger selectedPasswordIndex;

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;

- (IBAction)handlePanGesture:(id)sender;

@end

@implementation CPPassContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.delegate = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

static NSString *g_passEditorSegueName = @"CPPassEditorSegue";
static NSString *g_searchSegueName = @"CPSearchSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:g_passEditorSegueName]) {
        CPPassEditorViewController *passEditorViewController = segue.destinationViewController;
        passEditorViewController.password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.selectedPasswordIndex];
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint location = [panGesture locationInView:self.parentViewController.view];
    CGPoint velocity = [panGesture velocityInView:self.parentViewController.view];
    
    static CGPoint lastKnownVelocity;
    
    lastKnownVelocity = velocity;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self performSegueWithIdentifier:g_searchSegueName sender:self];
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.y / CGRectGetHeight(self.view.bounds);
        [self.percentDrivenInteractiveTransition updateInteractiveTransition:ratio];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (velocity.y > 0) {
            [self.percentDrivenInteractiveTransition finishInteractiveTransition];
        }
        else {
            [self.percentDrivenInteractiveTransition cancelInteractiveTransition];
        }
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPassCollectionViewCell" forIndexPath:indexPath];
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPasswordIndex = indexPath.row;
    self.selectedPasswordFrame = [collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    [self performSegueWithIdentifier:g_passEditorSegueName sender:self];
}

#pragma mark - UIGestureRecognizerDelegate implement

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) || ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    NSAssert(fromVC == self, @"");
    if ([toVC isMemberOfClass:[CPPassEditorViewController class]]) {
        return [[CPPassEditorTransition alloc] initWithReversed:NO];
    } else if ([toVC isMemberOfClass:[CPSearchViewController class]]) {
        return [[CPPanGestureTransition alloc] init];
    } else {
        NSAssert(NO, @"");
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isMemberOfClass:[CPPanGestureTransition class]]) {
        return self.percentDrivenInteractiveTransition;
    } else {
        return nil;
    }
}

#pragma mark - lazy init

- (UIPercentDrivenInteractiveTransition *)percentDrivenInteractiveTransition {
    if (!_percentDrivenInteractiveTransition) {
        _percentDrivenInteractiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
    }
    return _percentDrivenInteractiveTransition;
}

@end
