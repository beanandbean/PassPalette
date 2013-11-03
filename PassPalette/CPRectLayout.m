//
//  CPRectLayout.m
//  PassPalette
//
//  Created by wangyw on 11/2/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPRectLayout.h"

@interface CPRectLayout ()

@property (strong, nonatomic) NSArray *layoutAttributes;

@end

@implementation CPRectLayout

- (CGSize)collectionViewContentSize {
    return self.collectionView.frame.size;
}

- (void)prepareLayout {
    NSMutableArray *mutableLayoutAttribute = [NSMutableArray array];
    
    int count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        static const CGFloat topSeperator = 20.0;
        static const CGFloat seperator = 4.0;
        CGFloat width = (self.collectionView.frame.size.width - seperator) / 2;
        CGFloat height = (self.collectionView.frame.size.height - topSeperator - seperator * 4) / 4;
        int row = i / 2;
        int column = i % 2;
        attributes.frame = CGRectMake((width + seperator ) * column, topSeperator + (height + seperator) * row, width, height);
        [mutableLayoutAttribute addObject:attributes];
    }
    self.layoutAttributes = [mutableLayoutAttribute copy];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.layoutAttributes objectAtIndex:indexPath.row];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

@end
