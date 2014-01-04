//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPConstraintHelper.h"
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
@property (strong, nonatomic) UIView *backgroundSnapshotView;
@property (nonatomic) CGRect originalCellFrame;

@property (strong, nonatomic) NSLayoutConstraint *leftSnapshotConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rightSnapshotConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topSnapshotConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bottomSnapshotConstraint;

@property (strong, nonatomic) UIView *passEditorPanel;
@property (strong, nonatomic) CPPassMeterView *passMeterView;
@property (strong, nonatomic) UITextField *passTextField;
@property (strong, nonatomic) UILabel *memosTitle;
@property (strong, nonatomic) UICollectionView *memosCollectionView;

@property (strong, nonatomic) NSArray *sortedMemos;

@end

@implementation CPPassEditorManager

- (id)initWithPassword:(CPPassword *)password backgroundSnapshotView:(UIView *)backgroundSnapshotView originalCellFrame:(CGRect)originalCellFrame supermanager:(CPViewManager *)supermanager andSuperview:(UIView *)superview {
    self = [super initWithSupermanager:supermanager andSuperview:superview];
    if (self) {
        self.password = password;
        self.backgroundSnapshotView = backgroundSnapshotView;
        self.originalCellFrame = originalCellFrame;
    }
    return self;
}

- (void)loadViewsWithAnimation {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.superview addSubview:self.backgroundSnapshotView];
    
    [self loadPassEditorPanel];
    [self.superview layoutIfNeeded];
    
    // create pass editor snapshot
    UIView *passEditorSnapshot = [self.passEditorPanel snapshotViewAfterScreenUpdates:YES];
    passEditorSnapshot.alpha = 0.0;
    passEditorSnapshot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:passEditorSnapshot];
    
    // hide pass editor panel
    self.passEditorPanel.hidden = YES;
    
    // add constraints for the snapshot view
    CGRect destFrame = self.superview.bounds;
    CGFloat xScale = destFrame.size.width / self.originalCellFrame.size.width;
    CGFloat yScale = destFrame.size.height / self.originalCellFrame.size.height;
    self.leftSnapshotConstraint = [CPConstraintHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeLeft constant:0.0];
    self.rightSnapshotConstraint = [CPConstraintHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeRight constant:0.0];
    self.topSnapshotConstraint = [CPConstraintHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    self.bottomSnapshotConstraint = [CPConstraintHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
    [self.superview addConstraints:@[self.leftSnapshotConstraint, self.rightSnapshotConstraint, self.topSnapshotConstraint, self.bottomSnapshotConstraint]];
    
    // add constraints for the pass editor snapshot view
    NSLayoutConstraint *leftPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeLeft constant:self.originalCellFrame.origin.x];
    NSLayoutConstraint *rightPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeRight constant:-(destFrame.size.width - self.originalCellFrame.origin.x - self.originalCellFrame.size.width)];
    NSLayoutConstraint *topPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeTop constant:self.originalCellFrame.origin.y];
    NSLayoutConstraint *bottomPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeBottom constant:-(destFrame.size.height - self.originalCellFrame.origin.y - self.originalCellFrame.size.height)];
    [self.superview addConstraints:@[leftPassEditorSnapshotConstraint, rightPassEditorSnapshotConstraint, topPassEditorSnapshotConstraint, bottomPassEditorSnapshotConstraint]];
    [self.superview layoutIfNeeded];
    
    // enlarge snapshot view
    self.leftSnapshotConstraint.constant = -self.originalCellFrame.origin.x * xScale - 1;
    self.rightSnapshotConstraint.constant = (destFrame.size.width - self.originalCellFrame.origin.x - self.originalCellFrame.size.width) * xScale + 1;
    self.topSnapshotConstraint.constant = -self.originalCellFrame.origin.y * yScale - 1;
    self.bottomSnapshotConstraint.constant = (destFrame.size.height - self.originalCellFrame.origin.y - self.originalCellFrame.size.height) * yScale + 1;
    
    // enlarge pass editor snapshot view
    leftPassEditorSnapshotConstraint.constant = 0.0;
    rightPassEditorSnapshotConstraint.constant = 0.0;
    topPassEditorSnapshotConstraint.constant = 0.0;
    bottomPassEditorSnapshotConstraint.constant = 0.0;
    
    [CPProcessManager animateWithDuration:0.5 animations:^{
        passEditorSnapshot.alpha = 1.0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [passEditorSnapshot removeFromSuperview];
        self.passEditorPanel.hidden = NO;
    }];
}

- (void)unloadViewsWithAnimation {
    // create pass editor snapshot
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    UIView *passEditorSnapshot = [self.passEditorPanel snapshotViewAfterScreenUpdates:NO];
    passEditorSnapshot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:passEditorSnapshot];
    
    // remove pass editor panel
    [self.passEditorPanel removeFromSuperview];
    self.passEditorPanel = nil;
    
    // add constraints for the pass editor snapshot view
    CGRect destFrame = self.superview.bounds;
    NSLayoutConstraint *leftPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeLeft constant:0.0];
    NSLayoutConstraint *rightPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeRight constant:0.0];
    NSLayoutConstraint *topPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    NSLayoutConstraint *bottomPassEditorSnapshotConstraint = [CPConstraintHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
    [self.superview addConstraints:@[leftPassEditorSnapshotConstraint, rightPassEditorSnapshotConstraint, topPassEditorSnapshotConstraint, bottomPassEditorSnapshotConstraint]];
    [self.superview layoutIfNeeded];
    
    // shink snapshot view
    self.leftSnapshotConstraint.constant = 0.0;
    self.rightSnapshotConstraint.constant = 0.0;
    self.topSnapshotConstraint.constant = 0.0;
    self.bottomSnapshotConstraint.constant = 0.0;
    
    // shink pass editor snapshot view
    leftPassEditorSnapshotConstraint.constant = self.originalCellFrame.origin.x;
    rightPassEditorSnapshotConstraint.constant = -(destFrame.size.width - self.originalCellFrame.origin.x - self.originalCellFrame.size.width);
    topPassEditorSnapshotConstraint.constant = self.originalCellFrame.origin.y;
    bottomPassEditorSnapshotConstraint.constant = -(destFrame.size.height - self.originalCellFrame.origin.y - self.originalCellFrame.size.height);
    
    [CPProcessManager animateWithDuration:0.4 animations:^{
        passEditorSnapshot.alpha = 0.0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.supermanager dismissSubviewManager:self];
    }];
}

- (void)exitButtonPressed:(id)sender {
    if (STOP_PROCESS(EDITING_PASS_CELL_PROCESS)) {
        [self unloadViewsWithAnimation];
    }
}

- (void)addButtonPressed:(id)sender {
    static NSInteger index = 0;
    [[CPPassDataManager defaultManager] addMemoText:[NSString stringWithFormat:@"Test memo: %d", index++] inPassword:self.password];
    // force to reload
    self.sortedMemos = nil;
    [self.memosCollectionView reloadData];
}

- (void)loadPassEditorPanel {
    self.passEditorPanel.backgroundColor = [CPPassword colorOfEntropy:self.password.entropy];
    [self.superview addSubview:self.passEditorPanel];
    [self.superview addConstraints:[CPConstraintHelper constraintsWithView:self.passEditorPanel edgesAlignToView:self.superview]];
    
    // create mask
    UIView *mask = [[UIView alloc] init];
    mask.alpha = 0.6;
    mask.backgroundColor = [UIColor whiteColor];
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passEditorPanel addSubview:mask];
    [self.passEditorPanel addConstraints:[CPConstraintHelper constraintsWithView:mask edgesAlignToView:self.passEditorPanel]];
    
    // create front panel
    UIView *frontPanel = [[UIView alloc] init];
    frontPanel.backgroundColor = [UIColor clearColor];
    frontPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passEditorPanel addSubview:frontPanel];
    [self.passEditorPanel addConstraints:[CPConstraintHelper constraintsWithView:frontPanel edgesAlignToView:self.passEditorPanel]];
    
    // create pass meter
    self.passMeterView.entropy = self.password.entropy.doubleValue;
    [frontPanel addSubview:self.passMeterView];
    [frontPanel addConstraints:@[[CPConstraintHelper constraintWithView:self.passMeterView alignToView:frontPanel attribute:NSLayoutAttributeCenterX],
                            [CPConstraintHelper constraintWithView:self.passMeterView alignToView:frontPanel attribute:NSLayoutAttributeTop constant:20.0],
                            [CPConstraintHelper constraintWithView:self.passMeterView width:100.0],
                            [CPConstraintHelper constraintWithView:self.passMeterView height:100.0]]];
    
    // create exit button
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    exitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [frontPanel addSubview:exitButton];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:exitButton alignToView:self.passMeterView attribute:NSLayoutAttributeTop]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:exitButton alignToView:frontPanel attribute:NSLayoutAttributeRight constant:-8.0]];
    
    // create pass text field
    self.passTextField.text = self.password.text;
    self.passTextField.secureTextEntry = YES;
    [frontPanel addSubview:self.passTextField];
    [frontPanel addConstraints:[CPConstraintHelper constraintsWithView:self.passTextField alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:self.passTextField attribute:NSLayoutAttributeTop alignToView:self.passMeterView attribute:NSLayoutAttributeBottom]];
    [self.passTextField addConstraint:[CPConstraintHelper constraintWithView:self.passTextField height:44.0]];
    
    // create add memo button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [frontPanel addSubview:addButton];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:addButton attribute:NSLayoutAttributeTop alignToView:self.passTextField attribute:NSLayoutAttributeBottom]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:addButton alignToView:frontPanel attribute:NSLayoutAttributeRight constant:-8.0]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:addButton alignToView:exitButton attribute:NSLayoutAttributeWidth]];
    
    // create memos title
    [frontPanel addSubview:self.memosTitle];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle alignToView:addButton attribute:NSLayoutAttributeBaseline]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle alignToView:frontPanel attribute:NSLayoutAttributeLeft constant:8.0]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:self.memosTitle attribute:NSLayoutAttributeRight alignToView:addButton attribute:NSLayoutAttributeLeft]];
    
    // create line on the top of memos collection view
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor lightTextColor];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    [frontPanel addSubview:topLine];
    [frontPanel addConstraints:[CPConstraintHelper constraintsWithView:topLine alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:topLine attribute:NSLayoutAttributeTop alignToView:self.memosTitle attribute:NSLayoutAttributeBottom]];
    [topLine addConstraint:[CPConstraintHelper constraintWithView:topLine height:1]];
    
    // create memos collection view
    [frontPanel addSubview:self.memosCollectionView];
    [frontPanel addConstraints:[CPConstraintHelper constraintsWithView:self.memosCollectionView alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:self.memosCollectionView attribute:NSLayoutAttributeTop alignToView:topLine attribute:NSLayoutAttributeBottom]];
    
    // create line on the bottom of memos collection view
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor lightTextColor];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [frontPanel addSubview:bottomLine];
    [frontPanel addConstraints:[CPConstraintHelper constraintsWithView:bottomLine alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:bottomLine attribute:NSLayoutAttributeTop alignToView:self.memosCollectionView attribute:NSLayoutAttributeBottom]];
    [bottomLine addConstraint:[CPConstraintHelper constraintWithView:bottomLine height:1]];
    [frontPanel addConstraint:[CPConstraintHelper constraintWithView:bottomLine alignToView:frontPanel attribute:NSLayoutAttributeBottom]];
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

- (UIView *)passEditorPanel {
    if (!_passEditorPanel) {
        _passEditorPanel = [[UIView alloc] init];
        _passEditorPanel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _passEditorPanel;
}

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
