//
//  CPAdManager.m
//  Locor
//
//  Created by wangsw on 8/21/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPAdManager.h"

#import "CPUIKitHelper.h"
#import "CPHelperMacros.h"

#import "CPMainViewController.h"

// #import "Reachability.h"
// #import "GADBannerView.h"

@interface CPAdManager ()

@property (strong, nonatomic) ADBannerView *iAdBannerView;
// @property (strong, nonatomic) GADBannerView *gAdBannerView;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

// @property (strong, nonatomic) Reachability *appleReachability;

@end

@implementation CPAdManager

- (void)loadViewsWithAnimation {
    [self.superview addSubview:self.iAdBannerView];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.superview edgesAlignToView:self.iAdBannerView]];
    [self.superview addConstraint:self.heightConstraint];
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    // [self.appleReachability startNotifier];
    [self displayAdBanner];
    
    /*[self.superview addSubview:self.gAdBannerView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.superview edgesAlignToView:self.gAdBannerView]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.superview height:50.0]];
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [self.gAdBannerView loadRequest:request];*/
}

- (void)unloadViewsWithAnimation {
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    [self displayAdBanner];
}

- (void)displayAdBanner {
    // if (self.appleReachability.currentReachabilityStatus == NotReachable || !self.iAdBannerView.bannerLoaded) {
        // TODO: Use other advertisements when apple's iAd is not reachable.
        
        // self.heightConstraint.constant = 0.0;
        // self.iAdBannerView.hidden = YES;
    // } else {
    CGSize iAdSize = [self.iAdBannerView sizeThatFits:self.superview.bounds.size];
    self.heightConstraint.constant = iAdSize.height;
    self.iAdBannerView.hidden = NO;
    /// }
}

#pragma mark - AdBannerViewDelegate implementation

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self displayAdBanner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self displayAdBanner];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

#pragma mark - lazy init

- (ADBannerView *)iAdBannerView {
    if (!_iAdBannerView) {
        _iAdBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        
        _iAdBannerView.hidden = YES;
        _iAdBannerView.delegate = self;
        _iAdBannerView.translatesAutoresizingMaskIntoConstraints = NO;        
    }
    return _iAdBannerView;
}

/*- (GADBannerView *)gAdBannerView {
    if (!_gAdBannerView) {
        _gAdBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _gAdBannerView.adUnitID = @"a15242f40e06c1f";
        _gAdBannerView.rootViewController = [CPMainViewController mainViewController];
        _gAdBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _gAdBannerView;
}*/

- (NSLayoutConstraint *)heightConstraint {
    if (!_heightConstraint) {
        _heightConstraint = [CPUIKitHelper constraintWithView:self.superview height:0.0];
    }
    return _heightConstraint;
}

/*- (Reachability *)appleReachability {
    if (!_appleReachability) {
        _appleReachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    }
    return _appleReachability;
}*/
         
@end
