//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassEditorManager ()

@end

@implementation CPPassEditorManager

- (void)loadAnimated:(BOOL)animated {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.superview.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
}

@end
