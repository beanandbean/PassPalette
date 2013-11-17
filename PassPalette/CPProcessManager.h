//
//  CPProcessManager.h
//  PassPalette
//
//  Created by wangsw on 7/5/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPProcess.h"

#define IS_IN_PROCESS(process) [CPProcessManager isInProcess:process]
#define START_PROCESS(process) [CPProcessManager startProcess:process]
#define STOP_PROCESS(process) [CPProcessManager stopProcess:process]

#define INCREASE_FORBIDDEN_COUNT [CPProcessManager increaseForbiddenCount]
#define DECREASE_FORBIDDEN_COUNT [CPProcessManager decreaseForbiddenCount]

@interface CPProcessManager : NSObject

+ (bool)isInProcess:(id<CPProcess>)process;
+ (bool)startProcess:(id<CPProcess>)process;
+ (bool)stopProcess:(id<CPProcess>)process;

+ (void)increaseForbiddenCount;
+ (void)decreaseForbiddenCount;

@end
