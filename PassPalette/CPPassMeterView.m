//
//  CPPassMeter.m
//  PassPalette
//
//  Created by wangyw on 12/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassMeterView.h"

#import "CPUIKitHelper.h"

@interface CPPassMeterView ()

@property (strong, nonatomic) UILabel *label;

@end

@implementation CPPassMeterView

- (void)setEntropy:(double)entropy {
    _entropy = entropy;
    self.label.text = [NSString stringWithFormat:@"%2.1f", entropy];
    
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.label = [[UILabel alloc] init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.text = @"0";
        self.label.textColor = self.tintColor;
        self.label.font = [UIFont systemFontOfSize:50.0];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        [self addConstraints:[CPUIKitHelper constraintsWithView:self.label edgesAlignToView:self]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
}

@end
