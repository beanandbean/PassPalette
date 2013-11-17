//
//  CPMainViewController.h
//  PassPalette
//
//  Created by wangyw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

extern NSString *const CPDeviceOrientationWillChangeNotification;

@interface CPMainViewController : UIViewController

+ (CPMainViewController *)mainViewController;

+ (void)startDeviceOrientationWillChangeNotifier;
+ (void)stopDeviceOrientationWillChangeNotifier;

@end
