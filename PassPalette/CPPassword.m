//
//  CPPassword.m
//  Passtars
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

#import "CPHelperMacros.h"
#import "CPPassPaletteConfig.h"

@implementation CPPassword

@dynamic index;
@dynamic text;
@dynamic isUsed;
@dynamic colorIndex;
@dynamic icon;
@dynamic memos;

- (UIColor *)color {
    return [[UIColor alloc] initWithRed:PASSWORD_COLORS[self.colorIndex.intValue * 3] green:PASSWORD_COLORS[self.colorIndex.intValue * 3 + 1] blue:PASSWORD_COLORS[self.colorIndex.intValue * 3 + 2] alpha:1.0];
}

- (NSString *)displayIcon {
    return self.isUsed.boolValue ? self.icon : PASSWORD_DEFAULT_ICON;
}

- (NSString *)reversedIcon {
    return self.isUsed.boolValue ? PASSWORD_DEFAULT_ICON : self.icon;
}

@end
