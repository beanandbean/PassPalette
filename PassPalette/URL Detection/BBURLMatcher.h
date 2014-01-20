//
//  BBUrlMatcher.h
//  URLDetector
//
//  Created by wangsw on 10/24/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

@protocol BBURLMatcher <NSObject>

- (NSArray *)match:(NSString *)string;

@end
