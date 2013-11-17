//
//  CPMemoCollectionView.m
//  PassPalette
//
//  Created by wangyw on 11/14/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCollectionView.h"

@implementation CPMemoCollectionView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    }
    return self;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
}

@end
