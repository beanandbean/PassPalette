//
//  CPPassDataManager.h
//  PassPalette
//
//  Created by wangyw on 6/13/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CPMemo;
@class CPPassword;

@interface CPPassDataManager : NSObject

@property (strong, nonatomic) NSFetchedResultsController *passwordsController;

+ (CPPassDataManager *)defaultManager;

- (void)setText:(NSString *)text intoPassword:(CPPassword *)password;
- (void)setPasswordText:(NSString *)text atIndex:(NSUInteger)index;

- (CPMemo *)addMemoText:(NSString *)text inPassword:(CPPassword *)password;
- (CPMemo *)newMemoText:(NSString *)text inIndex:(NSUInteger)index;
- (void)setText:(NSString *)text ofMemo:(CPMemo *)memo;
- (void)removeMemo:(CPMemo *)memo;

- (void)exchangePasswordBetweenIndex1:(NSUInteger)index1 andIndex2:(NSUInteger)index2;

- (NSArray *)memosContainText:(NSString *)text;

- (void)saveContext;

@end
