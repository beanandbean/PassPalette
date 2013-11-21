//
//  CPMemCell.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemCell.h"

#import "CPAppearanceManager.h"

@implementation CPMemCell

+ (NSString *)reuseIdentifier {
    return @"MemoCollectionViewCell";
}

#pragma mark - editing

static UITextField *g_textField;

- (void)startEditing {
    if (!g_textField) {
        g_textField = [[UITextField alloc] init];
        g_textField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self.contentView addSubview:g_textField];
    [self.contentView addConstraints:[CPAppearanceManager constraintsWithView:g_textField edgesAlignToView:self.contentView]];
}

- (void)stopEditing {
    
}

#pragma mark - lazy init

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_label];
        [self.contentView addConstraints:[CPAppearanceManager constraintsWithView:_label edgesAlignToView:self.contentView]];
    }
    return _label;
}

@end
