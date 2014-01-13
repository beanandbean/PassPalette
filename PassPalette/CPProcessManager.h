//
//  CPProcessManager.h
//  PassPalette
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcess.h"

#define IS_CURRENT_PROCESS(process) [CPProcessManager isCurrentProcess:process]
#define IS_IN_PROCESS(process) [CPProcessManager isInProcess:process]
#define START_PROCESS(process) [CPProcessManager startProcess:process]
#define STOP_PROCESS(process) [CPProcessManager stopProcess:process]

@interface CPProcessManager : NSObject

+ (bool)isCurrentProcess:(id<CPProcess>)process;
+ (bool)isInProcess:(id<CPProcess>)process;
+ (bool)startProcess:(id<CPProcess>)process;
+ (bool)stopProcess:(id<CPProcess>)process;

+ (void)increaseForbiddenCount;
+ (void)decreaseForbiddenCount;

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;

@end
