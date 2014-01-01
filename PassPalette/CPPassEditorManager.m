//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPConstraintHelper.h"
#import "CPMainViewController.h"
#import "CPMemoCell.h"
#import "CPPassContainerManager.h"
#import "CPPassMeterView.h"

#import "BBPasswordStrength.h"
#import "CPMemo.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPEditingPassCellProcess.h"
#import "CPProcessManager.h"
#import "CPScrollingCollectionViewProcess.h"

@interface CPPassEditorManager ()

@property (weak, nonatomic) CPPassword *password;

@property (strong, nonatomic) CPPassMeterView *passMeterView;
@property (strong, nonatomic) UITextField *passTextField;
@property (strong, nonatomic) UILabel *memosTitle;

@property (strong, nonatomic) UICollectionView *memosCollectionView;

@property (strong, nonatomic) NSArray *sortedMemos;

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
    
    // create mask
    UIView *mask = [[UIView alloc] init];
    mask.alpha = 0.6;
    mask.backgroundColor = [UIColor whiteColor];
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:mask];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:mask edgesAlignToView:self.superview]];
    
    // create panel
    UIView *panel = [[UIView alloc] init];
    panel.backgroundColor = [UIColor clearColor];
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:panel];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:panel edgesAlignToView:self.superview]];
    
    // create pass meter
    self.passMeterView.entropy = self.password.entropy.doubleValue;
    [panel addSubview:self.passMeterView];
    [panel addConstraints:@[[CPConstraintHelper constraintWithView:self.passMeterView alignToView:panel attribute:NSLayoutAttributeCenterX],
                            [CPConstraintHelper constraintWithView:self.passMeterView alignToView:panel attribute:NSLayoutAttributeTop constant:20.0],
                            [CPConstraintHelper constraintWithView:self.passMeterView width:100.0],
                            [CPConstraintHelper constraintWithView:self.passMeterView height:100.0]]];
    
    // create exit button
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    exitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:exitButton];
    [panel addConstraint:[CPConstraintHelper constraintWithView:exitButton alignToView:self.passMeterView attribute:NSLayoutAttributeTop]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:exitButton alignToView:panel attribute:NSLayoutAttributeRight constant:-8.0]];
    
    // create pass text field
    self.passTextField.text = self.password.text;
    self.passTextField.secureTextEntry = YES;
    [panel addSubview:self.passTextField];
    [panel addConstraints:[CPConstraintHelper constraintsWithView:self.passTextField alignToView:panel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:self.passTextField attribute:NSLayoutAttributeTop alignToView:self.passMeterView attribute:NSLayoutAttributeBottom]];
    [self.passTextField addConstraint:[CPConstraintHelper constraintWithView:self.passTextField height:44.0]];
    
    // create add memo button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:addButton];
    [panel addConstraint:[CPConstraintHelper constraintWithView:addButton attribute:NSLayoutAttributeTop alignToView:self.passTextField attribute:NSLayoutAttributeBottom]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:addButton alignToView:panel attribute:NSLayoutAttributeRight constant:-8.0]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:addButton alignToView:exitButton attribute:NSLayoutAttributeWidth]];
    
    // create memos title
    [panel addSubview:self.memosTitle];
    [panel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle alignToView:addButton attribute:NSLayoutAttributeBaseline]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle alignToView:panel attribute:NSLayoutAttributeLeft constant:8.0]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle attribute:NSLayoutAttributeRight alignToView:addButton attribute:NSLayoutAttributeLeft]];
    
    // create line on the top of memos collection view
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor lightTextColor];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:topLine];
    [panel addConstraints:[CPConstraintHelper constraintsWithView:topLine alignToView:panel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:topLine attribute:NSLayoutAttributeTop alignToView:self.memosTitle attribute:NSLayoutAttributeBottom]];
    [topLine addConstraint:[CPConstraintHelper constraintWithView:topLine height:1]];
    
    // create memos collection view
    [panel addSubview:self.memosCollectionView];
    [panel addConstraints:[CPConstraintHelper constraintsWithView:self.memosCollectionView alignToView:panel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:self.memosCollectionView attribute:NSLayoutAttributeTop alignToView:topLine attribute:NSLayoutAttributeBottom]];

    // create line on the bottom of memos collection view
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor lightTextColor];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:bottomLine];
    [panel addConstraints:[CPConstraintHelper constraintsWithView:bottomLine alignToView:panel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:bottomLine attribute:NSLayoutAttributeTop alignToView:self.memosCollectionView attribute:NSLayoutAttributeBottom]];
    [bottomLine addConstraint:[CPConstraintHelper constraintWithView:bottomLine height:1]];
    [panel addConstraint:[CPConstraintHelper constraintWithView:bottomLine alignToView:panel attribute:NSLayoutAttributeBottom]];
}

- (void)exitButtonPressed:(id)sender {
    if (STOP_PROCESS(EDITING_PASS_CELL_PROCESS)) {
        CPPassContainerManager *passContainerManager = (CPPassContainerManager *)self.supermanager;
        [passContainerManager unloadPassEditor];
    }
}

- (void)addButtonPressed:(id)sender {
    static NSInteger index = 0;
    [[CPPassDataManager defaultManager] addMemoText:[NSString stringWithFormat:@"Test memo: %d", index++] inPassword:self.password];
    // force to reload
    self.sortedMemos = nil;
    [self.memosCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sortedMemos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CPMemoCell reuseIdentifier] forIndexPath:indexPath];
    CPMemo *memo = [self.sortedMemos objectAtIndex:indexPath.row];
    cell.label.text = memo.text;
    return cell;
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
    if (textField == self.passTextField) {
        self.passTextField.secureTextEntry = NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.passTextField) {
        [[CPPassDataManager defaultManager] setText:textField.text intoPassword:self.password];
        self.passTextField.secureTextEntry = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([password isEqualToString:@""]) {
        self.superview.backgroundColor = [UIColor grayColor];
    } else {
        BBPasswordStrength *passwordStrength = [[BBPasswordStrength alloc] initWithPassword:password];
        self.passMeterView.entropy = passwordStrength.entropy;
        self.superview.backgroundColor = [CPPassword colorOfEntropy:[NSNumber numberWithDouble:passwordStrength.entropy]];
    }
    
    return YES;
}

#pragma mark - lazy init

- (CPPassMeterView *)passMeterView {
    if (!_passMeterView) {
        _passMeterView = [[CPPassMeterView alloc] init];
        _passMeterView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passMeterView;
}

- (UITextField *)passTextField {
    if (!_passTextField) {
        _passTextField = [[UITextField alloc] init];
        _passTextField.backgroundColor = [UIColor lightTextColor];
        _passTextField.returnKeyType = UIReturnKeyDone;
        _passTextField.textAlignment = NSTextAlignmentCenter;
        _passTextField.textColor = [UIColor blackColor];
        _passTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _passTextField.delegate = self;
    }
    return _passTextField;
}

- (UILabel *)memosTitle {
    if (!_memosTitle) {
        _memosTitle = [[UILabel alloc] init];
        _memosTitle.text = @"Memos";
        _memosTitle.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _memosTitle;
}

- (UICollectionView *)memosCollectionView {
    if (!_memosCollectionView) {
        _memosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _memosCollectionView.dataSource = self;
        _memosCollectionView.delegate = self;
        _memosCollectionView.backgroundColor = [UIColor clearColor];
        _memosCollectionView.showsHorizontalScrollIndicator = NO;
        _memosCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_memosCollectionView registerClass:[CPMemoCell class] forCellWithReuseIdentifier:[CPMemoCell reuseIdentifier]];
        [_memosCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"123456"];
    }
    return _memosCollectionView;
}

- (NSArray *)sortedMemos {
    if (!_sortedMemos) {
        NSAssert(self.password != nil, @"");
        NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES]];
        _sortedMemos = [self.password.memos sortedArrayUsingDescriptors:sortDescriptors];
    }
    return _sortedMemos;
}

@end
