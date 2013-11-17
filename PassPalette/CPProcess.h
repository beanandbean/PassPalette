//
//  CPProcess.h
//  PassPalette
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

@protocol CPProcess <NSObject>

+ (id<CPProcess>)process;
- (BOOL)allowSubprocess:(id<CPProcess>)process;

@end
