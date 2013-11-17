//
//  CPPassword.h
//  PassPalette
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CPMemo;

@interface CPPassword : NSManagedObject

@property (strong, nonatomic) NSNumber *entropy;
@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSSet *memos;

+ (UIColor *)colorOfEntropy:(NSNumber *)entropy;

@end

@interface CPPassword (CoreDataGeneratedAccessors)

- (void)addMemosObject:(CPMemo *)value;
- (void)removeMemosObject:(CPMemo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
