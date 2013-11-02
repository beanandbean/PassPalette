//
//  CPMemo.h
//  Passtars
//
//  Created by wangyw on 6/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CPPassword;

@interface CPMemo : NSManagedObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) CPPassword *password;

@end
