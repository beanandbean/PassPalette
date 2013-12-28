//
//  CPPassEditorViewController.m
//  PassPalette
//
//  Created by wangyw on 12/26/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassEditorViewController.h"

#import "BBPasswordStrength.h"
#import "CPHeader.h"
#import "CPMemoCell.h"
#import "CPPassDataManager.h"
#import "CPPassEditorTransition.h"

@interface CPPassEditorViewController ()

@property (strong, nonatomic) NSMutableArray *memos;

@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *memosCollectionView;

- (IBAction)exit:(id)sender;
- (IBAction)addMemo:(id)sender;

@end

@implementation CPPassEditorViewController

- (void)setPassword:(CPPassword *)password {
    NSAssert(self.memos == nil, @"");
    
    _password = password;
    self.memos = [[password.memos allObjects] mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [CPPassword colorOfEntropy:self.password.entropy];;
    self.passTextField.text = self.password.text;
    self.passTextField.secureTextEntry = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.navigationController.delegate = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)exit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addMemo:(id)sender {
    static NSInteger index = 0;
    [self.memos addObject:[NSString stringWithFormat:@"Test memo: %d", index++]];
    [self.memosCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.memos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPMemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPMemoCell" forIndexPath:indexPath];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(30, cell.bounds.size.height - 1, cell.bounds.size.width, 1)];
    line.backgroundColor = [UIColor lightTextColor];
    [cell.contentView addSubview:line];
    cell.label.text = [self.memos objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, 30.0);
}

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return [[CPPassEditorTransition alloc] initWithReversed:YES];
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
        self.passTextField.secureTextEntry = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BBPasswordStrength *passwordStrength = [[BBPasswordStrength alloc] initWithPassword:password];
    self.view.backgroundColor = [CPPassword colorOfEntropy:[NSNumber numberWithDouble:passwordStrength.entropy]];
    
    return YES;
}

@end
