//
//  BBURLMatch.h
//  URLDetector
//
//  Created by wangsw on 10/24/13.
//  Copyright (c) 2013 beanandbean. All rights reserved.
//

typedef enum {
    BBURLMatchTypeFullURL,
    BBURLMatchTypeDictionary
} BBURLMatchType;

@interface BBURLMatch : NSObject

@property (nonatomic) BBURLMatchType type;
@property (nonatomic) int begin;
@property (nonatomic) int end;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *URL;

@end
