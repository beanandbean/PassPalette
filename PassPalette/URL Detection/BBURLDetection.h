//
//  BBURLDetector.h
//  URLDetector
//
//  Created by wangsw on 10/24/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

@interface BBURLDetection : NSObject

- (id)initWithString:(NSString *)string;

- (NSArray *)matches;

@end
