//
//  SelectAssetsVC.m
//  sample-chat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "SelectAssetsVC.h"
#import <Photos/Photos.h>
#import "UIView+Chat.h"
#import "SelectAssetCell.h"
#import <math.h>
#import "UIViewController+Alert.h"
#import "UICollectionView+Chat.h"
#import "UIViewController+Alert.h"

const CGFloat itemsInRow = 3.0f;
const double kMaximumMB = 90;
const double kDividerToMB = 1048576;
const CGFloat kMinimumSpacing = 8.0f;
NSString *const MAX_FILE_SIZE = @"The uploaded file exceeds maximum file size (100MB)";
NSString *const ERROR_IMAGE_LOAD = @"Error loading image";

@interface SelectAssetsVC () <UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver>
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *sendAttachmentButton;
@property (strong, nonatomic) PHAsset *selectedAsset;
@property (strong, nonatomic) PHFetchResult<id> *allPhotos;
@property (strong, nonatomic) PHCachingImageManager *cachingImageManager;
@property (assign, nonatomic) CGRect previousRect;
@property (assign, nonatomic) CGSize thumbnailImageSize;
@end

@implementation SelectAssetsVC
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    
    self.cachingImageManager = [[PHCachingImageManager alloc] init];
    [self reloadImages];
    
    [self.containerView roundTopCornersWithRadius:14.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width/itemsInRow - kMinimumSpacing * (itemsInRow - 1);
    self.thumbnailImageSize = CGSizeMake(width, width);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateCachedImages];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf reloadImages];
        [weakSelf.collectionView reloadData];
        [weakSelf updateCachedImages];
    });
}

- (void)reloadImages {
    [self stopCachingImages];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.includeAllBurstAssets = YES;
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    self.allPhotos = [PHAsset fetchAssetsWithOptions:fetchOptions];
}

#pragma mark - Internal Methods
- (void)stopCachingImages {
    [self.cachingImageManager stopCachingImagesForAllAssets];
    self.previousRect = CGRectZero;
}

- (void)updateCachedImages {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }

    CGRect originalRect = self.collectionView.bounds;
    originalRect = CGRectInset(originalRect, 0.0f, -0.5f * CGRectGetHeight(originalRect));

    CGFloat deltaY = ABS(CGRectGetMidY(originalRect) - CGRectGetMidY(self.previousRect));
    if (deltaY > CGRectGetHeight(originalRect) / 3.0f) {

        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self.collectionView compareHandlerWithRect:self.previousRect andRect:originalRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.cachingImageManager startCachingImagesForAssets:assetsStartCaching
                                            targetSize:self.thumbnailImageSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.cachingImageManager stopCachingImagesForAssets:assetsStopCaching
                                           targetSize:self.thumbnailImageSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousRect = originalRect;
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.allPhotos[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
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
    if (!self.selectedAsset) {return;}
    void(^sendAsset)(double size) = ^(double size) {
        double sizeMB = size/kDividerToMB;
        sizeMB = trunc(sizeMB * 100) / 100;
        if (sizeMB > kMaximumMB) {
            [self showAlertWithTitle:MAX_FILE_SIZE message:nil
                  fromViewController:self handler:nil];
        } else {
            self.sendAttachmentButton.enabled = NO;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            
            __weak typeof(self)weakSelf = self;
            [PHImageManager.defaultManager requestImageForAsset:self.selectedAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable resultImage, NSDictionary * _Nullable info) {
                __typeof(weakSelf)strongSelf = weakSelf;
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
                                fromViewController:strongSelf handler:^(UIAlertAction * _Nonnull action) {
                        strongSelf.sendAttachmentButton.enabled = NO;
                    }];
                }
            }];
        }
    };
    
    [self.selectedAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
        NSNumber *fileSize = nil;
        NSError *error = nil;
        [contentEditingInput.fullSizeImageURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
        sendAsset(fileSize.doubleValue);
    }];
    
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *phAsset = [self.allPhotos objectAtIndex:indexPath.item];
    
    SelectAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectAssetCell" forIndexPath:indexPath];
    cell.representedAssetIdentifier = phAsset.localIdentifier;
    [self.cachingImageManager requestImageForAsset:phAsset
                                        targetSize:self.thumbnailImageSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if ([cell.representedAssetIdentifier isEqualToString:phAsset.localIdentifier]) {
            cell.assetImageView.image = result;
        }
    }];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedImages];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedAsset = [self.allPhotos objectAtIndex:indexPath.item];
    self.sendAttachmentButton.hidden = !collectionView.indexPathsForSelectedItems.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = UIScreen.mainScreen.bounds.size.width/itemsInRow - kMinimumSpacing * (itemsInRow - 1);
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kMinimumSpacing;
}

@end
