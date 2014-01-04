//
//  CPSearchViewManager.h
//  PassPalette
//
//  Created by wangyw on 1/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

#import "CPInteractiveTransition.h"

@interface CPSearchViewManager : CPViewManager <CPInteractiveTransitioning, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

- (id)initWithBluredBackgroundImage:(UIImage *)bluredBackgroundImage Supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview;

@end
