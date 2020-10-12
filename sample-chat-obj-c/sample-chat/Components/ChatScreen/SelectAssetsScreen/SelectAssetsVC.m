//
//  SelectAssetsVC.m
//  samplechat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SelectAssetsVC.h"
#import <Photos/Photos.h>
#import "UIView+Chat.h"
#import "SelectAssetCell.h"
#import <math.h>
#import "SVProgressHUD.h"
#import "UIViewController+Alert.h"

const double kMaximumMB = 90;
const double kDividerToMB = 1048576;
const CGFloat kMinimumSpacing = 8.0f;
NSString *const MAX_FILE_SIZE = @"The uploaded file exceeds maximum file size (100MB)";
NSString *const ERROR_IMAGE_LOAD = @"Error loading image";

@interface SelectAssetsVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *sendAttachmentButton;
@property (strong, nonatomic) PHFetchResult<id> *allPhotos;
@property (strong, nonatomic) PHAsset *selectedAsset;
@end

@implementation SelectAssetsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchAssets];
    [self.containerView roundTopCornersWithRadius:14.0f];
}

#pragma mark - Actions
- (IBAction)cancelButtonTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedImage) {
            self.selectedImage(nil);
        }
    }];
}

- (IBAction)sendAttachmentButtonTapped:(UIButton *)sender {
    void(^sendAsset)(double size) = ^(double size) {
        double sizeMB = size/kDividerToMB;
        sizeMB = trunc(sizeMB * 100) / 100;
        if (sizeMB > kMaximumMB) {
            [self showAlertWithTitle:MAX_FILE_SIZE message:nil
                  fromViewController:self];
        } else {
            [SVProgressHUD show];
            self.sendAttachmentButton.enabled = NO;
            if (self.selectedAsset) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                __weak typeof(self)weakSelf = self;
                [PHImageManager.defaultManager requestImageForAsset:self.selectedAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable resultImage, NSDictionary * _Nullable info) {
                    __typeof(weakSelf)strongSelf = weakSelf;
                    [SVProgressHUD dismiss];
                    if (resultImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf dismissViewControllerAnimated:YES completion:^{
                                if (strongSelf.selectedImage) {
                                    strongSelf.selectedImage(resultImage);
                                }
                            }];
                        });
                        
                    } else {
                        [strongSelf showAlertWithTitle:ERROR_IMAGE_LOAD message:nil
                                    fromViewController:self];
                    }
                }];
            }
        }
    };
    
    if (self.selectedAsset) {
        [self.selectedAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            NSNumber *fileSize = nil;
            NSError *error = nil;
            [contentEditingInput.fullSizeImageURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
            sendAsset(fileSize.doubleValue);
        }];
    }
}

#pragma mark - Internal Methods
- (void)fetchAssets {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.allPhotos = nil;
    [self.collectionView reloadData];
    PHFetchResult<id> *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    if (allPhotos) {
        self.allPhotos = allPhotos;
        [self.collectionView reloadData];
        [SVProgressHUD dismiss];
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectAssetCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SelectAssetCell class]]) {
        SelectAssetCell *phAssetCell = (SelectAssetCell *)cell;
        PHAsset *phAsset = self.allPhotos[indexPath.row];
        CGSize size = phAssetCell.assetImageView.bounds.size;
        [PHImageManager.defaultManager requestImageForAsset:phAsset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            if (image) {
                phAssetCell.assetImageView.image = image;
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *phAsset = self.allPhotos[indexPath.row];
    if (!phAsset) {
        return;
    }
    self.selectedAsset = phAsset;
    self.sendAttachmentButton.hidden = !collectionView.indexPathsForSelectedItems.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemsInRow = 3.0f;
    CGFloat width = UIScreen.mainScreen.bounds.size.width/itemsInRow - kMinimumSpacing * (itemsInRow - 1);
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumSpacing;
}

@end
