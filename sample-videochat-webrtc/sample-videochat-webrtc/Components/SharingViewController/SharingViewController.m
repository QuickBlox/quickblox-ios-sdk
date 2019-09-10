//
//  SharingViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SharingViewController.h"
#import "ScreenCapture.h"
#import "SharingCell.h"
#import "Log.h"

@interface SharingViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) QBRTCVideoCapture *capture;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) ScreenCapture *screenCapture;
@property (nonatomic, copy) NSIndexPath *indexPath;

@end

static NSString * const reuseIdentifier = @"SharingCell";

@implementation SharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.images = @[@"pres_img_1", @"pres_img_2", @"pres_img_3"];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.enabled = self.session.localMediaStream.videoTrack.isEnabled;
    self.capture = self.session.localMediaStream.videoTrack.videoCapture;
    
    //Switch to sharing
    self.screenCapture = [[ScreenCapture alloc] initWithView:self.view];
    self.session.localMediaStream.videoTrack.videoCapture = self.screenCapture;
    
    self.collectionView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.enabled) {
        self.session.localMediaStream.videoTrack.enabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        
        if (!self.enabled) {
            self.session.localMediaStream.videoTrack.enabled = NO;
            self.session.localMediaStream.videoTrack.videoCapture = self.capture;
        }
    }
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SharingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                  forIndexPath:indexPath];
    cell.imageName = self.images[indexPath.row];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.bounds.size;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.indexPath =  [self.collectionView.indexPathsForVisibleItems firstObject];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.collectionView scrollToItemAtIndexPath:self.indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    self.indexPath = nil;
}

@end
