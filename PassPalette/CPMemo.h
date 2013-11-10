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

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) CPPassword *password;

@end
