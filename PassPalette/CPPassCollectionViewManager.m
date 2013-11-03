//
//  CPPassCollectionViewManager.m
//  Passtars
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassCollectionViewManager.h"

#import "CPAppearanceManager.h"
#import "CPRectLayout.h"

@interface CPPassCollectionViewManager ()

@property (strong, nonatomic) UICollectionView *passCollectionView;

@end

@implementation CPPassCollectionViewManager

- (void)loadAnimated:(BOOL)animated {
    [self.superview addSubview:self.passCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passCollectionView edgesAlignToView:self.superview]];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHue:0.1 * indexPath.row saturation:1.0 brightness:1.0 alpha:1.0];
    return cell;    
}

#pragma mark - lazy init

- (UICollectionView *)passCollectionView {
    if (!_passCollectionView) {
        _passCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[CPRectLayout alloc] init]];
        _passCollectionView.dataSource = self;
        _passCollectionView.delegate = self;
        _passCollectionView.translatesAutoresizingMaskIntoConstraints = NO;

        [_passCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CELL"];
    }
    return _passCollectionView;
}

@end
