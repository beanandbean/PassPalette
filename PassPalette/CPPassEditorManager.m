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
#import "CPMemoCollectionView.h"
#import "CPMemoCollectionViewLayout.h"
#import "CPPassContainerManager.h"

#import "BBPasswordStrength.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassEditorManager ()

@property (strong, nonatomic) UIView *passwordBackground;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *doneButton;

@property (strong, nonatomic) UIView *memosBackground;
@property (strong, nonatomic) CPMemoCollectionView *memoCollectionView;

@end

@implementation CPPassEditorManager

- (void)loadAnimated:(BOOL)animated {
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.index];
    self.superview.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
    
    [self.superview addSubview:self.passwordBackground];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordBackground alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [[CPMainViewController mainViewController].view addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[CPMainViewController mainViewController].topLayoutGuide attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    [self.passwordBackground addConstraint:[CPAppearanceManager constraintWithView:self.passwordBackground height:44.0]];
    
    self.passwordTextField.text = password.text;
    self.passwordTextField.secureTextEntry = YES;
    [self.superview addSubview:self.passwordTextField];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passwordBackground attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordTextField alignToView:self.passwordBackground attributes:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
    
    [self.superview addSubview:self.doneButton];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passwordBackground attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.doneButton alignToView:self.passwordBackground attributes:NSLayoutAttributeTop, NSLayoutAttributeBottom, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.doneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0]];
    
    [self createMemoCollectionView];
}

- (void)createMemoCollectionView {
    [self.superview addSubview:self.memosBackground];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.memosBackground alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memosBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordBackground attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memosBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0]];
    
    [self.superview addSubview:self.memoCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.memoCollectionView edgesAlignToView:self.memosBackground]];
}

- (void)doneButtonPressed:(id)sender {
    CPPassContainerManager *passContainerManager = (CPPassContainerManager *)self.supermanager;
    [passContainerManager unloadPassEditor];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MemoCollectionViewCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BBPasswordStrength *passwordStrength = [[BBPasswordStrength alloc] initWithPassword:password];
    self.superview.backgroundColor = [CPPassword colorOfEntropy:[NSNumber numberWithDouble:passwordStrength.entropy]];
    
    
    return YES;
}

#pragma mark - lazy init

- (UIView *)passwordBackground {
    if (!_passwordBackground) {
        _passwordBackground = [[UIView alloc] init];
        _passwordBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        _passwordBackground.alpha = 0.8;
        _passwordBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordBackground;
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

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIView *)memosBackground {
    if (!_memosBackground) {
        _memosBackground = [[UIView alloc] init];
        _memosBackground.backgroundColor = [[UIColor alloc] initWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
        _memosBackground.alpha = 0.8;
        _memosBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _memosBackground;
}

- (CPMemoCollectionView *)memoCollectionView {
    if (!_memoCollectionView) {
        _memoCollectionView = [[CPMemoCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[CPMemoCollectionViewLayout alloc] init]];
        _memoCollectionView.backgroundColor = [UIColor clearColor];
        _memoCollectionView.dataSource = self;
        _memoCollectionView.delegate = self;
        _memoCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_memoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MemoCollectionViewCell"];
    }
    return _memoCollectionView;
}

@end
