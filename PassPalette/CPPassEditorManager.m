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
#import "CPPassContainerManager.h"

#import "BBPasswordStrength.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPEditingPassCellProcess.h"
#import "CPProcessManager.h"
#import "CPScrollingCollectionViewProcess.h"

@interface CPPassEditorManager ()

@property (weak, nonatomic) CPPassword *password;

@property (strong, nonatomic) UIView *passwordBackground;
@property (strong, nonatomic) UIView *passwordPanel;

@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) CPColorBar *colorBar;

@property (strong, nonatomic) UICollectionView *memoCollectionView;

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
    
    [self loadPasswordViews];
    [self createMemoCollectionView];
}

- (void)loadPasswordViews {
    UIView *a = [[UIView alloc] init];
    a.backgroundColor = [UIColor blackColor];
    a.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:a];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:a alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, ATTR_END]];
    [a addConstraint:[CPAppearanceManager constraintWithView:a height:20.0]];
    
    [self.superview addSubview:self.passwordBackground];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordBackground alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:20.0]];
    [self.passwordBackground addConstraint:[CPAppearanceManager constraintWithView:self.passwordBackground height:44.0]];
    [self.superview addSubview:self.passwordPanel];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.passwordPanel edgesAlignToView:self.passwordBackground]];
    
    UIView *b = [[UIView alloc] init];
    b.backgroundColor = [UIColor whiteColor];
    b.alpha = 0.7;
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:b];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:b alignToView:self.superview attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordPanel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:2.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:b attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];

    self.passwordTextField.text = self.password.text;
    self.passwordTextField.secureTextEntry = YES;
    [self.passwordPanel addSubview:self.passwordTextField];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.passwordPanel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.passwordPanel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    
    [self.passwordPanel addSubview:self.doneButton];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.passwordPanel attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10.0]];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.doneButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10.0]];
    
    [self.passwordPanel addSubview:self.colorBar];
    [self.passwordPanel addConstraint:[CPAppearanceManager constraintWithView:self.colorBar alignToView:self.passwordTextField attribute:NSLayoutAttributeLeft]];
    [self.passwordPanel addConstraint:[CPAppearanceManager constraintWithView:self.colorBar attribute:NSLayoutAttributeTop alignToView:self.passwordTextField attribute:NSLayoutAttributeBottom]];
    [self.passwordPanel addConstraint:[NSLayoutConstraint constraintWithItem:self.colorBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.passwordTextField attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.colorBar addConstraint:[CPAppearanceManager constraintWithView:self.colorBar height:3.0]];
    self.colorBar.color = 1.0;
    
}

- (void)createMemoCollectionView {
    /*[self.superview addSubview:self.memoCollectionView];
    [self.superview addConstraints:[CPAppearanceManager constraintsWithView:self.memoCollectionView alignToView:self.background attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memoCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.colorBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.memoCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.background attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0]];*/
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"123456" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"Memos";
    [label sizeToFit];
    [view addSubview:label];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Add" forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:button];
    [view addConstraints:[CPAppearanceManager constraintsWithView:label edgesAlignToView:view]];
    [view addConstraints:[CPAppearanceManager constraintsWithView:button edgesAlignToView:view]];
    return view;
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 44.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, 44.0);
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
        _passwordBackground.backgroundColor = [UIColor whiteColor];
        _passwordBackground.alpha = 0.7;
        _passwordBackground.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordBackground;
}

- (UIView *)passwordPanel {
    if (!_passwordPanel) {
        _passwordPanel = [[UIView alloc] init];
        _passwordPanel.backgroundColor = [UIColor clearColor];
        _passwordPanel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passwordPanel;
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

- (UICollectionView *)memoCollectionView {
    if (!_memoCollectionView) {
        _memoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _memoCollectionView.dataSource = self;
        _memoCollectionView.delegate = self;
        _memoCollectionView.backgroundColor = [UIColor clearColor];
        _memoCollectionView.showsHorizontalScrollIndicator = NO;
        _memoCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_memoCollectionView registerClass:[CPMemCell class] forCellWithReuseIdentifier:[CPMemCell reuseIdentifier]];
        [_memoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"123456"];
    }
    return _memoCollectionView;
}

@end
