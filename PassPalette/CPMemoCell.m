//
//  CPMemCell.m
//  PassPalette
//
//  Created by wangyw on 11/17/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMemoCell.h"

#import "CPAppearanceManager.h"

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
    [self.contentView addConstraints:[CPAppearanceManager constraintsWithView:g_textField edgesAlignToView:self.contentView]];
}

- (void)stopEditing {
    
}

@end
