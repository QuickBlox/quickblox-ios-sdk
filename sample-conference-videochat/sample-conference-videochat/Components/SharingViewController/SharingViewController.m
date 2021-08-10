//
//  SharingViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SharingViewController.h"
#import "SharingCell.h"
#import "Log.h"
#import "ButtonsFactory.h"

@interface SharingViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) QBRTCVideoCapture *capture;
@property (nonatomic, strong) SharingScreenCapture *screenCapture;
@end

static NSString * const kSharingReuseIdentifier = @"SharingCell";

@implementation SharingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureGUI];

    self.images = @[@"pres_img_1", @"pres_img_2", @"pres_img_3"];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Switch to sharing
    
    VideoFormat *videoFormat = [[VideoFormat alloc] initWithWidth:UIScreen.mainScreen.bounds.size.width
                                                           height:UIScreen.mainScreen.bounds.size.height
                                                              fps:12];
    self.screenCapture = [[SharingScreenCapture alloc] initWithVideoFormat:videoFormat];
    [self startScreenSharing];
    
    
    [self showControls:YES];

}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.prefetchingEnabled = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = UIColor.blackColor;
    UINib *nibCell = [UINib nibWithNibName:kSharingReuseIdentifier bundle:nil];
    [self.collectionView registerNib:nibCell forCellWithReuseIdentifier:kSharingReuseIdentifier];
}

- (void)configureToolBar {
    __weak __typeof(self)weakSelf = self;
    
    CustomButton *screenShareEnabled = [ButtonsFactory screenShare];
    [self.toolbar addButton:screenShareEnabled action: ^(UIButton *sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.screenCapture = nil;
        [strongSelf stopScreenSharing];
        [strongSelf invalidateHideToolbarTimer];
        
        [strongSelf dismissViewControllerAnimated:NO completion:^{
            if (strongSelf.didCloseSharingVC) {
                strongSelf.didCloseSharingVC();
            }
        }];
    }];
    screenShareEnabled.pressed = YES;
    [self.toolbar updateItems];
}


#pragma mark - ReplayKit methods
- (void)startScreenSharing {
    
    __weak __typeof(self)weakSelf = self;
    [RPScreenRecorder.sharedRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
        if (error) {
            Log(@"[%@] RPScreenRecorder Error: %@",  NSStringFromClass(self.class), error.localizedDescription);
            return;
        }
        
        switch (bufferType) {
            case RPSampleBufferTypeVideo:{
                if (self.didSetupSharingScreenCapture) {
                    self.didSetupSharingScreenCapture(self.screenCapture);
                }
                
                CVPixelBufferRef source = CMSampleBufferGetImageBuffer(sampleBuffer);
                QBRTCVideoFrame *videoFrame = [[QBRTCVideoFrame alloc] initWithPixelBuffer:source videoRotation:QBRTCVideoRotation_0];
                [weakSelf.screenCapture sendVideoFrame:videoFrame];
                break;
            }
            default:
                break;
        }
        
    } completionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"%@ startCaptureWithHandler error: %@",NSStringFromClass([SharingViewController class]), error);
            return;
        }
        
        
    }];
}

- (void)stopScreenSharing {
    __weak __typeof(self)weakSelf = self;
    [RPScreenRecorder.sharedRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"%@ stopCaptureWithHandler error: %@",NSStringFromClass([SharingViewController class]), error);
        }
        weakSelf.screenCapture = nil;
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SharingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSharingReuseIdentifier
                                                                  forIndexPath:indexPath];
    cell.imageName = self.images[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showControls:YES];
}

@end
