//
//  CPPassword.m
//  PassPalette
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

@implementation CPPassword

@dynamic entropy;
@dynamic index;
@dynamic text;
@dynamic memos;

+ (UIColor *)colorOfEntropy:(NSNumber *)entropy {
    return [UIColor colorWithHue:0.667 - entropy.doubleValue / 75.0 saturation:1.0 brightness:1.0 alpha:1.0];
}

@end
