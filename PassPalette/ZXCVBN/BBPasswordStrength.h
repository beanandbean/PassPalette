//
//  BBPasswordStrength.h
//  ZXCVBN
//
//  Created by wangsw on 10/18/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

@interface BBPasswordStrength : NSObject

- (id)initWithPassword:(NSString *)password;

- (double)strength;
- (double)entropy;
- (double)crackTime;
- (NSString *)password;
- (NSArray *)matchSequence;
- (NSString *)crackTimeDisplay;

@end
