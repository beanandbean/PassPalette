//
//  CPPassMeter.m
//  PassPalette
//
//  Created by wangyw on 12/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassMeter.h"

#import "CPAppearanceManager.h"

@implementation CPPassMeter

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = @"55";
        label.textColor = self.tintColor;
        label.font = [UIFont systemFontOfSize:50.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [self addConstraints:[CPAppearanceManager constraintsWithView:label edgesAlignToView:self]];
    }
    return self;
}

@end
