//
//  CPPassContainerManager.h
//  PassPalette
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

@interface CPPassContainerManager : CPViewManager <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

- (void)unloadPassEditor;

@end
