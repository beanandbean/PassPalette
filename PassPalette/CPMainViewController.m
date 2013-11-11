//
//  CPMainViewController.m
//  Passtars
//
//  Created by wangyw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPRootManager.h"

NSString *const CPDeviceOrientationWillChangeNotification = @"DEVICE_ROTATION_NOTIFICATION";

static int g_deviceOrientationWillChangeNotifierRequestCount = 0;

@interface CPMainViewController ()

@property (strong, nonatomic) CPRootManager *rootManager;

@end

@implementation CPMainViewController

+ (CPMainViewController *)mainViewController {
    return (CPMainViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

+ (void)startDeviceOrientationWillChangeNotifier {
    g_deviceOrientationWillChangeNotifierRequestCount++;
}

+ (void)stopDeviceOrientationWillChangeNotifier {
    if (g_deviceOrientationWillChangeNotifierRequestCount > 0) {
        g_deviceOrientationWillChangeNotifierRequestCount--;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.rootManager loadAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (g_deviceOrientationWillChangeNotifierRequestCount > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPDeviceOrientationWillChangeNotification object:[NSNumber numberWithInteger:toInterfaceOrientation]];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - lazy init

- (CPRootManager *)rootManager {
    if (!_rootManager) {
        _rootManager = [[CPRootManager alloc] initWithSupermanager:nil andSuperview:self.view];
    }
    return _rootManager;
}

@end
