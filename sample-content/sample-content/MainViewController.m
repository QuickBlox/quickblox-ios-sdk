//
//  ViewController.m
//  sample-content
//
//  Created by Quickblox Team on 6/9/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "ContentViewController.h"
#import "Storage.h"
#import "ImageCollectionViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD.h>

static NSString* const kImageCellIdentifier = @"ImageCollectionViewCellIdentifier";

@interface MainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) UILabel *footerLabel;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) QBGeneralResponsePage* page;

@end

@implementation MainViewController

- (QBGeneralResponsePage *)page
{
    if (_page == nil) {
        _page = [QBGeneralResponsePage responsePageWithCurrentPage:0 perPage:10];
    }
    return _page;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.allowsEditing = NO;
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return _imagePicker;
}

- (NSMutableArray *)items
{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([QBSession currentSession].currentUser == nil) {
        __weak typeof(self)weakSelf = self;
        [QBRequest logInWithUserLogin:@"igorquickblox2" password:@"igorquickblox2" successBlock:^(QBResponse *response, QBUUser *user) {
            __typeof(self) strongSelf = weakSelf;
            
            [strongSelf fetchNextPage];
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error %@:", response.error);
        }];
    } else {
        [self fetchNextPage];
    }
}

- (IBAction)addNewPicture:(id)sender
{
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - 
#pragma mark Helpers

- (void)fetchNextPage
{
    self.page.currentPage += 1;
    __weak typeof(self)weakSelf = self;
    [QBRequest blobsForPage:self.page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *blobs) {
        __typeof(self) strongSelf = weakSelf;
        
        [strongSelf.items addObjectsFromArray:blobs];
        [strongSelf.collectionView reloadData];
        
    } errorBlock:^(QBResponse *response) {
        NSLog(@"error: %@", response.error);
    }];
}


#pragma mark -
#pragma mark UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellIdentifier forIndexPath:indexPath];
    
    QBCBlob* blob = self.items[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:blob.privateUrl]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(160.0f, 160.0f);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

#pragma mark -
#pragma mark UICollectionViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight) {
        [self fetchNextPage];
    }
}
#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// when photo is selected from gallery - > upload it to server
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(selectedImage);

    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    // Upload file to QuickBlox cloud
    //
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithStatus:@"Uploading image"];
    [QBRequest TUploadFile:imageData fileName:@"iOS Content-Sample image" contentType:@"image/png" isPublic:NO
              successBlock:^(QBResponse *response, QBCBlob *blob) {
                  [SVProgressHUD dismiss];
                  
                  __typeof(self) strongSelf = weakSelf;
                  
                  [strongSelf.items addObject:blob];
                  [strongSelf.collectionView reloadData];
                  
                  // save it
                  [[Storage instance].filesList addObject:blob];
              } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                  [SVProgressHUD showProgress:status.percentOfCompletion status:@"Uploading image"];
              } errorBlock:^(QBResponse *response) {
                  [SVProgressHUD dismiss];
                  //
                  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error while uploading new file"
                                                                  message:[response.error description]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
                  [alert show];
              }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
