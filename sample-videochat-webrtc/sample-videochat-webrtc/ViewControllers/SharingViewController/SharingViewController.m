//
//  SharingViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 27/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SharingViewController.h"
#import "QBRTCScreenCapture.h"
#import "SharingCell.h"

@interface SharingViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, weak) QBRTCVideoCapture *capture;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) QBRTCScreenCapture *screenCapture;
@property (nonatomic, copy) NSIndexPath *indexPath;

@end

static NSString * const reuseIdentifier = @"SharingCell";

@implementation SharingViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.pagingEnabled = YES;
    self.images = @[@"pres_img_1", @"pres_img_2", @"pres_img_3"];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.enabled = self.session.localMediaStream.videoTrack.isEnabled;
    
    self.capture = self.session.localMediaStream.videoTrack.videoCapture;
    self.screenCapture = [[QBRTCScreenCapture alloc] initWithView:self.view];
    //Switch to sharing
    self.session.localMediaStream.videoTrack.videoCapture = self.screenCapture;
    self.collectionView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.enabled) {
        self.session.localMediaStream.videoTrack.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        
        if (!self.enabled) {
            self.session.localMediaStream.videoTrack.enabled = NO;
        }
        
        self.session.localMediaStream.videoTrack.videoCapture = self.capture;
    }
}

#pragma mark <UICollectionViewDataSource>

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
    self.collectionView.alpha = 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    self.collectionView.alpha = 1;
    
    [self.collectionView scrollToItemAtIndexPath:self.indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    self.indexPath = nil;
}
    

@end
