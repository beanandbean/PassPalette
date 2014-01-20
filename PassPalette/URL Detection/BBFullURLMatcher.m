//
//  BBFullURLMatcher.m
//  URLDetector
//
//  Created by wangsw on 10/24/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

#import "BBFullURLMatcher.h"

#import "BBURLMatch.h"

static NSRegularExpression *g_regex;

@implementation BBFullURLMatcher

- (NSArray *)match:(NSString *)string {
    if (!g_regex) {
        g_regex = [NSRegularExpression regularExpressionWithPattern:@"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9.-]+(:[0-9]+)?|(?:www.|[-;:&=\\+\\$,\\w]+@)[A-Za-z0-9.-]+)((?:\\/[\\+~%\\/.\\w-_]*)?\\??(?:[-\\+=&;%@.\\w_]*)#?(?:[\\w]*))?)" options:0 error:nil];
    }
    
    NSArray *results = [g_regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *result in results) {
        NSRange range = result.range;
        int begin = (int)range.location;
        int end = (int)range.location + (int)range.length - 1;
        NSString *url = [string substringWithRange:range];
        
        BBURLMatch *match = [[BBURLMatch alloc] init];
        match.type = BBURLMatchTypeFullURL;
        match.begin = begin;
        match.end = end;
        match.token = url;
        match.URL = url;
        [matches addObject:match];
    }
    
    return matches;
}

@end
