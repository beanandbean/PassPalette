//
//  CPConstraintHelper.m
//  PassPalette
//
//  Created by wangyw on 1/1/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPUIKitHelper.h"

const NSLayoutAttribute ATTR_END = -1;

@implementation CPUIKitHelper

+ (void)enableControlsInView:(UIView *)view {
    for (id subview in view.subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            [subview setEnabled:YES];
        }
        [self enableControlsInView:subview];
    }
}

+ (UIView *)maskWithColor:(UIColor *)color alpha:(CGFloat)alpha {
    UIView *mask = [[UIView alloc] init];
    mask.backgroundColor = color;
    mask.alpha = alpha;
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    return mask;
}

+ (NSArray *)constraintsWithView:(id)view1 edgesAlignToView:(id)view2 {
    return [CPUIKitHelper constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END];
}

+ (NSArray *)constraintsWithView:(id)view1 centerAlignToView:(id)view2 {
    return [CPUIKitHelper constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeCenterX, NSLayoutAttributeCenterY, ATTR_END];
}

+ (NSArray *)constraintsWithView:(id)view1 alignToView:(id)view2 attributes:(NSLayoutAttribute)firstAttr, ... {
    NSMutableArray *result = [NSMutableArray array];
    
    NSLayoutAttribute eachAttr;
    va_list attrList;
    if (firstAttr != ATTR_END) {
        [result addObject:[CPUIKitHelper constraintWithView:view1 alignToView:view2 attribute:firstAttr]];
        va_start(attrList, firstAttr);
        while ((eachAttr = va_arg(attrList, NSLayoutAttribute)) != ATTR_END) {
            [result addObject:[CPUIKitHelper constraintWithView:view1 alignToView:view2 attribute:eachAttr]];
        }
        va_end(attrList);
    }
    
    return result;
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2 {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr constant:(CGFloat)c {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:c];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2 constant:(CGFloat)c {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:c];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view width:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view height:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

@end
