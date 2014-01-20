//
//  CPRainbowColors.m
//  PassPalette
//
//  Created by wangyw on 1/19/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPRainbow.h"

@implementation CPRainbow

@synthesize colors = _colors;

- (NSArray *)colors {
    if (!_colors) {
        NSMutableArray *colors = [NSMutableArray array];
        for (CGFloat hue = 0.0; hue < 1.0; hue += 1.0 / 360) {
            [colors addObject:[UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0]];
        }
        _colors = [colors copy];
    }
    return _colors;
}

- (UIColor *)colorOfPassStrength:(double)strength {
    return [self.colors objectAtIndex:strength * self.colors.count];
}

@end
