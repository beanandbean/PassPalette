//
//  CPMemCell.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPUIKitHelper.h"

@interface CPMemoCell ()

@property (strong, nonatomic) UIView *line;

@end

@implementation CPMemoCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.label];
        [self addConstraints:[CPUIKitHelper constraintsWithView:self.label alignToView:self attributes:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
        [self addConstraint:[CPUIKitHelper constraintWithView:self.label alignToView:self attribute:NSLayoutAttributeLeft constant:8.0]];
        [self addConstraint:[CPUIKitHelper constraintWithView:self.label alignToView:self attribute:NSLayoutAttributeRight constant:-8.0]];
        
        [self addSubview:self.line];
        [self addConstraint:[CPUIKitHelper constraintWithView:self.line alignToView:self attribute:NSLayoutAttributeLeft constant:8.0]];
        [self addConstraint:[CPUIKitHelper constraintWithView:self.line alignToView:self attribute:NSLayoutAttributeRight]];
        [self addConstraint:[CPUIKitHelper constraintWithView:self.line alignToView:self attribute:NSLayoutAttributeBottom]];
        [self.line addConstraint:[CPUIKitHelper constraintWithView:self.line height:1.0]];
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"CPMemoCell";
}

- (void)setShowBackgroundColor:(BOOL)showBackgroundColor {
    _showBackgroundColor = showBackgroundColor;
    if (_showBackgroundColor) {
        [self.line removeFromSuperview];
    }
}

#pragma mark - lazy init

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _label;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
        _line.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _line;
}

@end
