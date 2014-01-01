//
//  CPConstraintHelper.h
//  PassPalette
//
//  Created by wangyw on 1/1/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

extern const NSLayoutAttribute ATTR_END;

@interface CPConstraintHelper : NSObject

+ (NSArray *)constraintsWithView:(UIView *)view1 edgesAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 centerAlignToView:(UIView *)view2;
+ (NSArray *)constraintsWithView:(UIView *)view1 alignToView:(UIView *)view2 attributes:(NSLayoutAttribute)attr, ...;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr constant:(CGFloat)c;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(UIView *)view2 attribute:(NSLayoutAttribute)attr2 constant:(CGFloat)c;

+ (NSLayoutConstraint *)constraintWithView:(UIView *)view width:(CGFloat)width;
+ (NSLayoutConstraint *)constraintWithView:(UIView *)view height:(CGFloat)height;

@end
