//
//  CPPassword.h
//  Passtars
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CPMemo;

@interface CPPassword : NSManagedObject

@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSSet *memos;

@property (strong, readonly, nonatomic) UIColor *color;

+ (UIColor *)colorOfPassword:(NSString *)password;

@end

@interface CPPassword (CoreDataGeneratedAccessors)

- (void)addMemosObject:(CPMemo *)value;
- (void)removeMemosObject:(CPMemo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
