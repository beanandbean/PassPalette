//
//  CPAppearenceManager.h
//  PassPalette
//
//  Created by wangyw on 1/19/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPColorTable.h"

@interface CPAppearenceManager : NSObject

@property (strong, nonatomic) id<CPColorTable> colorTable;

+ (CPAppearenceManager *)defaultManager;

@end
