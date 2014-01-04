//
//  CPPassEditorManager.h
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPViewManager.h"

#import "CPPassword.h"

@interface CPPassEditorManager : CPViewManager <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

- (id)initWithPassword:(CPPassword *)password backgroundSnapshotView:(UIView *)backgroundSnapshotView originalCellFrame:(CGRect)originalCellFrame supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview;

@end
