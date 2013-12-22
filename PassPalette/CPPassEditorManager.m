//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPAppearanceManager.h"
#import "CPColorBar.h"
#import "CPMainViewController.h"
#import "CPMemCell.h"
#import "CPMemoCollectionView.h"
#import "CPMemoCollectionViewLayout.h"
#import "CPPassContainerManager.h"

#import "BBPasswordStrength.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPEditingPassCellProcess.h"
#import "CPProcessManager.h"
#import "CPScrollingCollectionViewProcess.h"

@interface CPPassEditorManager ()

@property (weak, nonatomic) CPPassword *password;

@property (strong, nonatomic) UIView *background;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) CPColorBar *colorBar;

@property (strong, nonatomic) CPMemoCollectionView *memoCollectionView;

@end

@implementation CPPassEditorManager

- (id)initWithPassword:(CPPassword *)password supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.password = password;
    }
    return self;
}

- (void)loadAnimated:(BOOL)animated {
    self.superview.backgroundColor = [CPPassword colorOfEntropy:self.password.entropy];
    
    [self.superview addSubview:self.background];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.background alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [[CPMainViewController mainViewController].view addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[CPMainViewController mainViewController].topLayoutGuide attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0]];
    
    self.passwordTextField.text = self.password.text;
    self.passwordTextField.secureTextEntry = YES;
    [self.superview addSubview:self.passwordTextField];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0]];
    
    [self.superview addSubview:self.doneButton];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.doneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0]];
    
    [self.superview addSubview:self.colorBar];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.colorBar alignToView:self.passwordTextField attribute:NSLayoutAttributeLeft]];
    [self.superview addConstraint:[CPAppearanceManager constraintWithView:self.colorBar attribute:NSLayoutAttributeTop alignToView:self.passwordTextField attribute:NSLayoutAttributeBottom]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.colorBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.colorBar addConstraint:[CPAppearanceManager constraintWithView:self.colorBar height:3.0]];
    self.colorBar.color = 1.0;
    
    [self createMemoCollectionView];
}

- (void)createMemoCollectionView {
    [self.superview addSubview:self.memoCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.memoCollectionView alignToView:self.background attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memoCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memoCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0]];
}

- (void)doneButtonPressed:(id)sender {
    if (STOP_PROCESS(EDITING_PASS_CELL_PROCESS)) {
        CPPassContainerManager *passContainerManager = (CPPassContainerManager *)self.supermanager;
        [passContainerManager unloadPassEditor];
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (IS_IN_PROCESS(SCROLLING_COLLECTION_VIEW_PROCESS)) {
        return self.password.memos.count + 1;
    } else {
        return self.password.memos.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CPMemCell reuseIdentifier] forIndexPath:indexPath];
    cell.label.text = @"1111111";
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

- (UIView *)background {
    if (!_background) {
        _background = [[UIView alloc] init];
        _background.backgroundColor = [UIColor whiteColor];
        _background.alpha = 0.8;
        _background.layer.cornerRadius = 10.0;
        _background.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _background;
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

- (CPColorBar *)colorBar {
    if (!_colorBar) {
        _colorBar = [[CPColorBar alloc] init];
        _colorBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _colorBar;
}

- (CPMemoCollectionView *)memoCollectionView {
    if (!_memoCollectionView) {
        _memoCollectionView = [[CPMemoCollectionView alloc] init];
        _memoCollectionView.dataSource = self;
        _memoCollectionView.delegate = self;
    }
    return _memoCollectionView;
}

@end
