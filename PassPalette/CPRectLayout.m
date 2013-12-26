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
    CGSize size = self.collectionView.bounds.size;
    size.height -= 20.0;
    return size;
}

- (void)prepareLayout {
    NSMutableArray *mutableLayoutAttribute = [NSMutableArray array];
    
    int count = [self.collectionView numberOfItemsInSection:0];
    static const CGFloat topSeperator = 0.0;
    static const CGFloat seperator = 4.0;
    CGFloat width = (self.collectionViewContentSize.width - seperator) / 2;
    CGFloat height = (self.collectionViewContentSize.height - topSeperator - seperator * 3) / 4;
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
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
    return YES;
}

@end
