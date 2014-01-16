//
//  CPPassEditorManager.m
//  PassPalette
//
//  Created by wangyw on 11/10/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorManager.h"

#import "CPUIKitHelper.h"
#import "CPMemoCell.h"
#import "CPPassContainerManager.h"
#import "CPPassMeterView.h"

#import "BBPasswordStrength.h"
#import "CPMemo.h"
#import "CPPassDataManager.h"
#import "CPPassword.h"

#import "CPMemoAddingProcess.h"
#import "CPMemoEdittingProcess.h"
#import "CPPassEdittingProcess.h"
#import "CPProcessManager.h"

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
@property (strong, nonatomic) UICollectionView *memosCollectionView;

@property (strong, nonatomic) UIView *memoTextFieldPanel;
@property (strong, nonatomic) UITextField *memoTextField;

@property (strong, nonatomic) NSArray *sortedMemos;

@property (strong, nonatomic) NSIndexPath *indexOfEdittingMemoCell;

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
    self.leftSnapshotConstraint = [CPUIKitHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeLeft constant:0.0];
    self.rightSnapshotConstraint = [CPUIKitHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeRight constant:0.0];
    self.topSnapshotConstraint = [CPUIKitHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    self.bottomSnapshotConstraint = [CPUIKitHelper constraintWithView:self.backgroundSnapshotView alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
    [self.superview addConstraints:@[self.leftSnapshotConstraint, self.rightSnapshotConstraint, self.topSnapshotConstraint, self.bottomSnapshotConstraint]];
    
    // add constraints for the pass editor snapshot view
    NSLayoutConstraint *leftPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeLeft constant:self.originalCellFrame.origin.x];
    NSLayoutConstraint *rightPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeRight constant:-(destFrame.size.width - self.originalCellFrame.origin.x - self.originalCellFrame.size.width)];
    NSLayoutConstraint *topPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeTop constant:self.originalCellFrame.origin.y];
    NSLayoutConstraint *bottomPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeBottom constant:-(destFrame.size.height - self.originalCellFrame.origin.y - self.originalCellFrame.size.height)];
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
    NSLayoutConstraint *leftPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeLeft constant:0.0];
    NSLayoutConstraint *rightPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeRight constant:0.0];
    NSLayoutConstraint *topPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeTop constant:0.0];
    NSLayoutConstraint *bottomPassEditorSnapshotConstraint = [CPUIKitHelper constraintWithView:passEditorSnapshot alignToView:self.superview attribute:NSLayoutAttributeBottom constant:0.0];
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
    if (IS_CURRENT_PROCESS(MEMO_ADDING_PROCESS) && STOP_PROCESS(MEMO_ADDING_PROCESS)) {
        [self unloadMemoTextField];
    } else if (IS_CURRENT_PROCESS(MEMO_EDITTING_PROCESS) && STOP_PROCESS(MEMO_EDITTING_PROCESS)) {
        [self unloadMemoTextField];
    }
    if (STOP_PROCESS(PASS_EDITTING_PROCESS)) {
        [self unloadViewsWithAnimation];
    }
}

- (void)addButtonPressed:(id)sender {
    if (START_PROCESS(MEMO_ADDING_PROCESS)) {
        [self.memosCollectionView setContentOffset:CGPointMake(0.0, -44.0) animated:YES];
        [self loadMemoTextFieldWithText:@""];
    }
}

- (void)loadPassEditorPanel {
    self.passEditorPanel.backgroundColor = [CPPassword colorOfEntropy:self.password.entropy];
    [self.superview addSubview:self.passEditorPanel];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.passEditorPanel edgesAlignToView:self.superview]];
    
    // create mask
    UIView *mask = [[UIView alloc] init];
    mask.alpha = 0.6;
    mask.backgroundColor = [UIColor whiteColor];
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passEditorPanel addSubview:mask];
    [self.passEditorPanel addConstraints:[CPUIKitHelper constraintsWithView:mask edgesAlignToView:self.passEditorPanel]];
    
    // create front panel
    UIView *frontPanel = [[UIView alloc] init];
    frontPanel.backgroundColor = [UIColor clearColor];
    frontPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.passEditorPanel addSubview:frontPanel];
    [self.passEditorPanel addConstraints:[CPUIKitHelper constraintsWithView:frontPanel edgesAlignToView:self.passEditorPanel]];
    
    // create pass meter
    self.passMeterView.entropy = self.password.entropy.doubleValue;
    [frontPanel addSubview:self.passMeterView];
    [frontPanel addConstraints:@[[CPUIKitHelper constraintWithView:self.passMeterView alignToView:frontPanel attribute:NSLayoutAttributeCenterX],
                            [CPUIKitHelper constraintWithView:self.passMeterView alignToView:frontPanel attribute:NSLayoutAttributeTop constant:20.0],
                            [CPUIKitHelper constraintWithView:self.passMeterView width:100.0],
                            [CPUIKitHelper constraintWithView:self.passMeterView height:100.0]]];
    
    // create exit button
    UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    exitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [frontPanel addSubview:exitButton];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:exitButton alignToView:self.passMeterView attribute:NSLayoutAttributeTop]];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:exitButton alignToView:frontPanel attribute:NSLayoutAttributeRight constant:-8.0]];
    
    // create pass text field
    self.passTextField.text = self.password.text;
    self.passTextField.secureTextEntry = YES;
    [frontPanel addSubview:self.passTextField];
    [frontPanel addConstraints:[CPUIKitHelper constraintsWithView:self.passTextField alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, ATTR_END]];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:self.passTextField attribute:NSLayoutAttributeTop alignToView:self.passMeterView attribute:NSLayoutAttributeBottom]];
    [self.passTextField addConstraint:[CPUIKitHelper constraintWithView:self.passTextField height:44.0]];
    
    // create add memo button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [frontPanel addSubview:addButton];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:addButton attribute:NSLayoutAttributeBottom alignToView:self.passTextField attribute:NSLayoutAttributeTop]];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:addButton alignToView:frontPanel attribute:NSLayoutAttributeRight constant:-8.0]];
    // [frontPanel addConstraint:[CPConstraintHelper constraintWithView:addButton alignToView:exitButton attribute:NSLayoutAttributeWidth]];
    
    // create memos collection view
    [frontPanel addSubview:self.memosCollectionView];
    [frontPanel addConstraints:[CPUIKitHelper constraintsWithView:self.memosCollectionView alignToView:frontPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom,  ATTR_END]];
    [frontPanel addConstraint:[CPUIKitHelper constraintWithView:self.memosCollectionView attribute:NSLayoutAttributeTop alignToView:self.passTextField attribute:NSLayoutAttributeBottom]];
}

- (void)loadMemoTextFieldWithText:(NSString *)text {
    [self.superview addSubview:self.memoTextFieldPanel];
    [self.superview addConstraints:[CPUIKitHelper constraintsWithView:self.memoTextFieldPanel edgesAlignToView:self.memosCollectionView]];
    self.memoTextField.text = text;
    [self.memoTextField becomeFirstResponder];
}

- (void)unloadMemoTextField {
    [self.memoTextFieldPanel removeFromSuperview];
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
    if (START_PROCESS(MEMO_EDITTING_PROCESS)) {
        self.indexOfEdittingMemoCell = indexPath;
        CPMemoCell *cell = (CPMemoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [CPProcessManager animateWithDuration:0.3 animations:^{
            collectionView.contentOffset = cell.frame.origin;
        } completion:^(BOOL finished) {
            cell.hidden = YES;
            [self loadMemoTextFieldWithText:cell.label.text];
        }];
    }
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
    } else if (textField == self.memoTextField) {
        if (IS_CURRENT_PROCESS(MEMO_ADDING_PROCESS) && STOP_PROCESS(MEMO_ADDING_PROCESS)) {
            CPMemo *memo = nil;
            if (![self.memoTextField.text isEqualToString:@""]) {
                memo = [[CPPassDataManager defaultManager] addMemoText:self.memoTextField.text inPassword:self.password];
                self.sortedMemos = nil;
                [self.memosCollectionView reloadData];
            }
            [self unloadMemoTextField];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sortedMemos indexOfObject:memo] inSection:0];
            [self.memosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        } else if (IS_CURRENT_PROCESS(MEMO_EDITTING_PROCESS) && STOP_PROCESS(MEMO_EDITTING_PROCESS)) {
            CPMemoCell *edittingMemoCell = (CPMemoCell *)[self.memosCollectionView cellForItemAtIndexPath:self.indexOfEdittingMemoCell];
            edittingMemoCell.hidden = NO;
            CPMemo *memo = [self.sortedMemos objectAtIndex:self.indexOfEdittingMemoCell.row];
            NSAssert(memo != nil, @"should find editing memo");
            if (![self.memoTextField.text isEqualToString:@""]) {
                [[CPPassDataManager defaultManager] setText:self.memoTextField.text ofMemo:memo];
                self.sortedMemos = nil;
                [self.memosCollectionView reloadData];
            }
            [self unloadMemoTextField];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sortedMemos indexOfObject:memo] inSection:0];
            [self.memosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.passTextField) {
        NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([password isEqualToString:@""]) {
            self.superview.backgroundColor = [UIColor grayColor];
        } else {
            BBPasswordStrength *passwordStrength = [[BBPasswordStrength alloc] initWithPassword:password];
            self.passMeterView.entropy = passwordStrength.entropy;
            self.passEditorPanel.backgroundColor = [CPPassword colorOfEntropy:[NSNumber numberWithDouble:passwordStrength.entropy]];
        }
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

- (UIView *)memoTextFieldPanel {
    if (!_memoTextFieldPanel) {
        _memoTextFieldPanel = [[UIView alloc] init];
        _memoTextFieldPanel.translatesAutoresizingMaskIntoConstraints = NO;

        [_memoTextFieldPanel addSubview:self.memoTextField];
        [_memoTextFieldPanel addConstraint:[CPUIKitHelper constraintWithView:self.memoTextField alignToView:_memoTextFieldPanel attribute:NSLayoutAttributeTop]];
        [_memoTextFieldPanel addConstraint:[CPUIKitHelper constraintWithView:self.memoTextField alignToView:_memoTextFieldPanel attribute:NSLayoutAttributeLeft constant:8.0]];
        [_memoTextFieldPanel addConstraint:[CPUIKitHelper constraintWithView:self.memoTextField alignToView:_memoTextFieldPanel attribute:NSLayoutAttributeRight constant:-8.0]];
        [self.memoTextField addConstraint:[CPUIKitHelper constraintWithView:self.memoTextField height:44.0]];
        
        UIView *mask = [CPUIKitHelper maskWithColor:[UIColor blackColor] alpha:0.8];
        [_memoTextFieldPanel addSubview:mask];
        [_memoTextFieldPanel addConstraints:[CPUIKitHelper constraintsWithView:mask alignToView:self.memoTextFieldPanel attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, ATTR_END]];
        [self.memoTextFieldPanel addConstraint:[CPUIKitHelper constraintWithView:mask attribute:NSLayoutAttributeTop alignToView:self.memoTextField attribute:NSLayoutAttributeBottom]];
    }
    return _memoTextFieldPanel;
}

- (UITextField *)memoTextField {
    if (!_memoTextField) {
        _memoTextField = [[UITextField alloc] init];
        _memoTextField.backgroundColor = [UIColor clearColor];
        _memoTextField.returnKeyType = UIReturnKeyDone;
        _memoTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _memoTextField.delegate = self;
    }
    return _memoTextField;
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
