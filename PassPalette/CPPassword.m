//
//  CPPassword.m
//  Passtars
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

#import "BBPasswordStrength.h"

@implementation CPPassword

@dynamic index;
@dynamic text;
@dynamic memos;

@synthesize color = _color;

+ (UIColor *)colorOfPassword:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];
    double entropyperchar = strength.entropy / password.length;
    entropyperchar = round(entropyperchar * 1000) / 1000;
    
    return [UIColor colorWithHue:0.667 - strength.entropy / 75 saturation:1.0 brightness:1.0 alpha:1.0];
}

- (UIColor *)color {
    if (!_color) {
        _color = [CPPassword colorOfPassword:self.text];
    }
    return _color;
}

@end
