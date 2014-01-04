//
//  CPMainViewController.m
//  PassPalette
//
//  Created by wangyw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPMainViewController.h"

#import "CPHomeManager.h"
#import "CPProcessManager.h"

NSString *const CPDeviceOrientationWillChangeNotification = @"DEVICE_ROTATION_NOTIFICATION";

static int g_deviceOrientationWillChangeNotifierRequestCount = 0;

@interface CPMainViewController ()

@property (strong, nonatomic) CPHomeManager *homeManager;

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
    [self.homeManager loadViewsWithAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (g_deviceOrientationWillChangeNotifierRequestCount > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CPDeviceOrientationWillChangeNotification object:[NSNumber numberWithInteger:toInterfaceOrientation]];
    }
}

#pragma mark - lazy init

- (CPHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[CPHomeManager alloc] initWithSupermanager:nil andSuperview:self.view];
    }
    return _homeManager;
}

@end
