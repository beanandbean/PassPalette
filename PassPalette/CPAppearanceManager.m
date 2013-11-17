//
//  CPAppearanceManager.m
//  PassPalette
//
//  Created by wangsw on 7/7/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAppearanceManager.h"

#import "CPHelperMacros.h"

#import "CPProcessManager.h"

const NSLayoutAttribute ATTR_END = -1;

@implementation CPAppearanceManager

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations {
    INCREASE_FORBIDDEN_COUNT;
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        DECREASE_FORBIDDEN_COUNT;
    }];
}

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion {
    INCREASE_FORBIDDEN_COUNT;
    [UIView animateWithDuration:duration animations:animations completion:^(BOOL finished) {
        DECREASE_FORBIDDEN_COUNT;
        if (completion) {
            completion(finished);
        }
    }];
}

+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion { 
    delayBlock(delay, ^{
        INCREASE_FORBIDDEN_COUNT;
        [UIView animateWithDuration:duration delay:0.0 options:options animations:animations completion:^(BOOL finished) {
            DECREASE_FORBIDDEN_COUNT;
            if (completion) {
                completion(finished);
            }
        }];
    });
}

#pragma mark - Constraint Helper

+ (NSArray *)constraintsWithView:(UIView *)view1 edgesAlignToView:(UIView *)view2 {
    return [CPAppearanceManager constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END];
}

+ (NSArray *)constraintsWithView:(UIView *)view1 centerAlignToView:(UIView *)view2 {
    return [CPAppearanceManager constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeCenterX, NSLayoutAttributeCenterY, ATTR_END];
}

+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2 attributes:(NSLayoutAttribute)firstAttr, ... {
    NSMutableArray *result = [NSMutableArray array];
    
    NSLayoutAttribute eachAttr;
    va_list attrList;
    if (firstAttr != ATTR_END) {
        [result addObject:[CPAppearanceManager constraintWithView:view1 alignToView:view2 attribute:firstAttr]];
        va_start(attrList, firstAttr);
        while ((eachAttr = va_arg(attrList, NSLayoutAttribute)) != ATTR_END) {
            [result addObject:[CPAppearanceManager constraintWithView:view1 alignToView:view2 attribute:eachAttr]];
        }
        va_end(attrList);
    }
    
    return result;
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2 {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view width:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view height:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

@end
