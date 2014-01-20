//
//  BBURLDictionaryMatcher.m
//  URLDetector
//
//  Created by wangsw on 10/29/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

#import "BBURLDictionaryMatcher.h"

#import "BBURLMatch.h"

static NSDictionary *g_websiteDictionary;

@implementation BBURLDictionaryMatcher

+ (void)initializeWebsiteDictionary {
    if (!g_websiteDictionary) {
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"website_dictionary" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        g_websiteDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    }
}

- (NSArray *)match:(NSString *)string {
    NSMutableArray *results = [NSMutableArray array];
    int length = (int)string.length;
    NSString *lower = string.lowercaseString;
    
    for (int i = 0; i < length; i++) {
        for (int j = i; j < length; j++) {
            unichar prev, succ;
            if (i > 0) {
                prev = [lower characterAtIndex:i - 1];
            } else {
                prev = ' ';
            }
            if (j < length - 1) {
                succ = [lower characterAtIndex:j + 1];
            } else {
                succ = ' ';
            }
            
            if (![[NSCharacterSet alphanumericCharacterSet] characterIsMember:prev] && ![[NSCharacterSet alphanumericCharacterSet] characterIsMember:succ]) {
                NSString *key = [lower substringWithRange:NSMakeRange(i, j - i + 1)];
                NSString *url = [g_websiteDictionary objectForKey:key];
                if (url) {
                    BBURLMatch *match = [[BBURLMatch alloc] init];
                    match.type = BBURLMatchTypeDictionary;
                    match.begin = i;
                    match.end = j;
                    match.token = [string substringWithRange:NSMakeRange(i, j - i + 1)];
                    match.URL = url;
                    [results addObject:match];
                }
            }
        }
    }
    
    return results;
}

@end
