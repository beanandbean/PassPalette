//
//  CPPassEditorViewController.h
//  PassPalette
//
//  Created by wangyw on 12/26/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassword.h"

@interface CPPassEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) CPPassword *password;

@end
