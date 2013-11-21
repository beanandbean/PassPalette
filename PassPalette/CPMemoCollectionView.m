//
//  CPMemoCollectionView.m
//  PassPalette
//
//  Created by wangyw on 11/14/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionView.h"

#import "CPAppearanceManager.h"

#import "CPMemCell.h"
#import "CPMemoCollectionViewLayout.h"

#import "CPRemovingMemoCellProcess.h"
#import "CPScrollingCollectionViewProcess.h"

@interface CPMemoCollectionView ()

@end

@implementation CPMemoCollectionView

- (id)init {
    self = [super initWithFrame:CGRectZero collectionViewLayout:[[CPMemoCollectionViewLayout alloc] init]];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsHorizontalScrollIndicator = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self registerClass:[CPMemCell class] forCellWithReuseIdentifier:[CPMemCell reuseIdentifier]];
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        if (!IS_IN_PROCESS(REMOVING_MEMO_CELL_PROCESS) && !IS_IN_PROCESS(SCROLLING_COLLECTION_VIEW_PROCESS)) {
            CGPoint location = [panGesture locationInView:panGesture.view];
            NSIndexPath *panningCellIndex = [self indexPathForItemAtPoint:location];
            
            if (fabsf(translation.x) > fabsf(translation.y) && panningCellIndex) {
            } else {
                if (START_PROCESS(SCROLLING_COLLECTION_VIEW_PROCESS)) {
                    [self reloadData];
                }
            }
        }
        if (IS_IN_PROCESS(SCROLLING_COLLECTION_VIEW_PROCESS)) {
            CGPoint offset = CGPointMake(self.contentOffset.x, self.contentOffset.y - translation.y);
            self.contentOffset = offset;
            
            CPMemCell *addingCell = (CPMemCell *)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (addingCell && offset.y < 30.0) {
                addingCell.label.text = @"Release to add a new memo";
            } else {
                addingCell.label.text = @"Drag to add a new memo";
            }
        }
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        if (STOP_PROCESS(SCROLLING_COLLECTION_VIEW_PROCESS)) {
            if (self.contentOffset.y < 0.0) {
                [self setContentOffset:CGPointZero animated:YES];
            } else if (self.contentOffset.y > self.contentSize.height - self.bounds.size.height) {
                [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height - self.bounds.size.height) animated:YES];
            }
        }
    }
}

@end
