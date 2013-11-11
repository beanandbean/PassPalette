//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPAppearanceManager.h"
#import "CPMainViewController.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassEditorManager ()

@property (strong, nonatomic) UIView *passwordTextFieldBackground;
@property (strong, nonatomic) UITextField *passwordTextField;

@end

@implementation CPPassEditorManager

- (void)loadAnimated:(BOOL)animated {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.superview.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
    
    [self.superview addSubview:self.passwordTextFieldBackground];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordTextFieldBackground alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [[CPMainViewController mainViewController].view addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[CPMainViewController mainViewController].topLayoutGuide attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    [self.passwordTextFieldBackground addConstraint:[CPAppearanceManager constraintWithView:self.passwordTextFieldBackground height:44.0]];
    
    self.passwordTextField.text = password.text;
    [self.passwordTextFieldBackground addSubview:self.passwordTextField];
    [self.passwordTextFieldBackground addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    [self.passwordTextFieldBackground addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passwordTextFieldBackground attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
    [self.passwordTextFieldBackground addConstraints:[CPAppearanceManager constraintsWithView:self.passwordTextField alignToView:self.passwordTextFieldBackground attributes:NSLayoutAttributeTop, NSLayoutAttributeHeight, ATTR_END]];
}

#pragma mark - UITextFieldDelegate implement
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        self.passwordTextField.secureTextEntry = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /*if (!range.location && range.length == textField.text.length && [string isEqualToString:@""]) {
        if (self.allowEdit) {
            self.allowEdit = NO;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = NO;
            }];
        }
    } else if ([textField.text isEqualToString:@""]) {
        if (!self.allowEdit) {
            self.allowEdit = YES;
            [CPAppearanceManager animateWithDuration:0.3 animations:^{
                self.cellIcon.enabled = self.memoCollectionViewManager.enabled = YES;
            }];
        }
    }*/
    
    return YES;
}

#pragma mark - lazy init

- (UIView *)passwordTextFieldBackground {
    if (!_passwordTextFieldBackground) {
        _passwordTextFieldBackground = [[UIView alloc] init];
        _passwordTextFieldBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        _passwordTextFieldBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordTextFieldBackground;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.textColor = [UIColor blackColor];
        _passwordTextField.backgroundColor = [UIColor clearColor];
        _passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

@end
