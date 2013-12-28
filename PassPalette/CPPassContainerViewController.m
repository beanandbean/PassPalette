//
//  CPPassContainerViewController.m
//  PassPalette
//
//  Created by wangyw on 12/25/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPPassContainerViewController.h"

#import "CPPassEditorViewController.h"

#import "CPPassDataManager.h"
#import "CPPassword.h"

@interface CPPassContainerViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *passCollectionView;

@property (nonatomic) NSUInteger selectedPasswordIndex;

@end

@implementation CPPassContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

static NSString *g_passEditorSegueName = @"CPPassEditorSegue";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:g_passEditorSegueName]) {
        CPPassEditorViewController *passEditorViewController = segue.destinationViewController;
        passEditorViewController.password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:self.selectedPasswordIndex];
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPassCollectionViewCell" forIndexPath:indexPath];
    CPPassword *password = [[CPPassDataManager defaultManager].passwordsController.fetchedObjects objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = [CPPassword colorOfEntropy:password.entropy];
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedPasswordIndex = indexPath.row;
    self.selectedPasswordFrame = [collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
    [self performSegueWithIdentifier:g_passEditorSegueName sender:self];
}

@end
