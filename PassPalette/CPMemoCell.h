//
//  CPMemCell.h
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@interface CPMemoCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *label;

+ (NSString *)reuseIdentifier;

@end
