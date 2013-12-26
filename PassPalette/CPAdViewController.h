//
//  CPAdViewController.h
//  PassPalette
//
//  Created by wangyw on 12/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import <iAd/iAd.h>

@interface CPAdViewController : UIViewController <ADBannerViewDelegate>

- (id)initWithContentViewController:(UIViewController *)contentViewController;

@end
