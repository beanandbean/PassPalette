//
//  CPPassMeter.m
//  PassPalette
//
//  Created by wangyw on 12/28/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassMeterView.h"

#import "CPAppearenceManager.h"
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
    
    id<CPColorTable> colorTable = [CPAppearenceManager defaultManager].colorTable;
    CGFloat interval = M_PI * 2 / colorTable.colors.count;
    for (NSUInteger index = 0; index < colorTable.colors.count; ++index) {
        CGFloat startAngle = index * interval;
        CGFloat nextAngle = startAngle + interval;
        CGContextAddArc(context, centerX, centerY, centerX, startAngle, nextAngle, 0);
        CGContextAddArc(context, centerX, centerY, centerX - 10.0, nextAngle, startAngle, 1);
        CGContextClosePath(context);
        CGContextSetFillColorWithColor(context, [[colorTable.colors objectAtIndex:index] CGColor]);
        CGContextFillPath(context);
    }
}

@end
