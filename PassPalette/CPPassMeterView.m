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
    self.label.text = [NSString stringWithFormat:@"%2.0f", entropy];
    [self setNeedsDisplay];
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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat centerY = self.bounds.size.height / 2;
    CGContextBeginPath(context);
    
    CGFloat startAngle = 0.0;
    CGFloat endAngle = self.entropy * 360.0 / 50.0;
    CGFloat interval = 10.0;
    while (startAngle < endAngle) {
        CGFloat nextAngle = startAngle + interval;
        CGFloat startRadian = [self radianOfAngle:startAngle];
        CGFloat nextRadian = [self radianOfAngle:nextAngle];
        CGContextAddArc(context, centerX, centerY, centerX, startRadian, nextRadian + 0.01, 0);
        CGContextAddArc(context, centerX, centerY, centerX - 10.0, nextRadian + 0.01, startRadian, 1);
        CGContextClosePath(context);
        UIColor *color = [UIColor colorWithHue:startAngle / 360.0 saturation:1.0 brightness:1.0 alpha:1.0];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
        startAngle = nextAngle;
    }
}

- (CGFloat)radianOfAngle:(CGFloat)angle {
    return (angle - 90.0) * M_PI / 180.0;
}

@end

