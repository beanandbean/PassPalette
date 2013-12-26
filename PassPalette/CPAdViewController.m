//
//  CPAdViewController.m
//  PassPalette
//
//  Created by wangyw on 12/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAdViewController.h"

@interface CPAdViewController ()

@property (strong, nonatomic) UIViewController *contentViewController;

@property (strong, nonatomic) ADBannerView *adBannerView;

@end

@implementation CPAdViewController

- (id)initWithContentViewController:(UIViewController *)contentViewController {
    NSAssert(contentViewController != nil, @"");
    self = [super init];
    if (self != nil) {
        self.contentViewController = contentViewController;
        self.adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        self.adBannerView.delegate = self;
    }
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:self.adBannerView];
    
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    bannerFrame.size = [self.adBannerView sizeThatFits:contentFrame.size];
    
    if (self.adBannerView.bannerLoaded) {
        contentFrame.size.height -= bannerFrame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    self.contentViewController.view.frame = contentFrame;
    self.adBannerView.frame = bannerFrame;
    
    [self.contentViewController.view setNeedsLayout];
    [self.contentViewController.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - AdBannerViewDelegate implementation

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self.view setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

@end
