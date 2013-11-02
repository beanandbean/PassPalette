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

@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSNumber *isUsed;
@property (nonatomic, retain) NSNumber *colorIndex;
@property (nonatomic, retain) NSString *icon;
@property (nonatomic, retain) NSSet *memos;

- (UIColor *)color;

- (NSString *)displayIcon;
- (NSString *)reversedIcon;

@end

@interface CPPassword (CoreDataGeneratedAccessors)

- (void)addMemosObject:(CPMemo *)value;
- (void)removeMemosObject:(CPMemo *)value;
- (void)addMemos:(NSSet *)values;
- (void)removeMemos:(NSSet *)values;

@end
