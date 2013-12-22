//
//  CPColorBar.m
//  PassPalette
//
//  Created by wangyw on 12/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPColorBar.h"

@interface CPColorBar ()

@property (strong, nonatomic) CALayer *mask;
@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation CPColorBar

- (id)init {
    self = [super init];
    if (self) {
        [self.layer addSublayer:self.mask];
        [self.mask addSublayer:self.gradient];
    }
    return self;
}

- (void)setColor:(CGFloat)color {
    _color = color;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.bounds;
    frame.size.width *= self.color;
    self.mask.frame = frame;
    self.gradient.frame = self.bounds;
}

#pragma - mark lazy init

- (CALayer *)mask {
    if (!_mask) {
        _mask = [CAGradientLayer layer];
        _mask.masksToBounds = YES;
    }
    return _mask;
}

- (CAGradientLayer *)gradient {
    if (!_gradient) {
        _gradient = [CAGradientLayer layer];
        _gradient.startPoint = CGPointMake(0.0, 0.0);
        _gradient.endPoint = CGPointMake(1.0, 0.0);
        _gradient.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.4],
                               [NSNumber numberWithFloat:0.4],
                               [NSNumber numberWithFloat:0.58],
                               [NSNumber numberWithFloat:0.62],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        _gradient.colors = [NSArray arrayWithObjects:
                            (id)[UIColor colorWithHue:300.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:360.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:0.0 / 360 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:30.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:30.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:60.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:240.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:180.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:180.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            (id)[UIColor colorWithHue:120.0 / 360.0 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                            nil];
    }
    return _gradient;
}

@end
