//
//  CPColorTable.h
//  PassPalette
//
//  Created by wangyw on 1/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@protocol CPColorTable <NSObject>

@property (strong, nonatomic) NSArray *colors;

- (UIColor *)colorOfPassStrength:(double)strength;

@end
