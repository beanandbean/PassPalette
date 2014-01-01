//
//  CPMemCell.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPConstraintHelper.h"

@interface CPMemoCell ()

@end

@implementation CPMemoCell

+ (NSString *)reuseIdentifier {
    return @"CPMemoCell";
}

#pragma mark - editing

static UITextField *g_textField;

- (void)startEditing {
    if (!g_textField) {
        g_textField = [[UITextField alloc] init];
        g_textField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self.contentView addSubview:g_textField];
    [self.contentView addConstraints:[CPConstraintHelper constraintsWithView:g_textField edgesAlignToView:self.contentView]];
}

- (void)stopEditing {
    
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        [self addConstraints:[CPConstraintHelper constraintsWithView:_label edgesAlignToView:self]];
    }
    return _label;
}

@end
