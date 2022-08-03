//
//  SharingViewController.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SharingViewController.h"
#import "SharingCell.h"
#import "Log.h"
#import "CallActionsBar.h"
#import "CallGradientView.h"
#import "CallAction.h"
#import "VideoFormat.h"

#import <ReplayKit/ReplayKit.h>

@interface SharingViewController () <UICollectionViewDelegateFlowLayout>
//MARK: - IBOutlets
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet CallActionsBar *actionsBar;
@property (weak, nonatomic) IBOutlet CallGradientView *bottomView;
//MARK: - Properties
@property (nonatomic, strong) NSArray *images;
@end

static NSString * const reuseIdentifier = @"SharingCell";

@implementation SharingViewController
//MARK: - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak __typeof(self)weakSelf = self;
    [self.actionsBar setupWithActions:@[
        [[CallAction alloc] initWithType:CallActionShare action:^(ActionButton * _Nonnull sender) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        [RPScreenRecorder.sharedRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
            Log(@"[%@] RPScreenRecorder Error: %@",  NSStringFromClass(self.class), error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.mediaController.sharingEnabled = NO;
                [strongSelf.navigationController popViewControllerAnimated:NO];
            });
        }];
    }]
    ]];
    
    [self.actionsBar select:YES type:CallActionShare];
    [self.bottomView setupGradientWithFirstColor:[UIColor.blackColor colorWithAlphaComponent:0.0f]
                                  andSecondColor:[UIColor.blackColor colorWithAlphaComponent:0.7f]];
    self.images = @[@"pres_img_1", @"pres_img_2", @"pres_img_3"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startSharing];
}

//MARK: - Private Methods
- (void)startSharing {
    __weak __typeof(self)weakSelf = self;
    [RPScreenRecorder.sharedRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer,
                                                               RPSampleBufferType bufferType,
                                                               NSError * _Nullable error) {
        if (error) {
            Log(@"[%@] RPScreenRecorder Error: %@",  NSStringFromClass(self.class), error.localizedDescription);
            return;
        }
        
        switch (bufferType) {
            case RPSampleBufferTypeVideo:
                [self.mediaController sendScreenContent:CMSampleBufferGetImageBuffer(sampleBuffer)];
                break;
            case RPSampleBufferTypeAudioApp: break;
            case RPSampleBufferTypeAudioMic: break;
        }
    } completionHandler:^(NSError * _Nullable error) {
        if (error) {
            Log(@"[%@] RPScreenRecorder Error: %@",  NSStringFromClass(self.class), error.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mediaController.videoFormat = [[VideoFormat alloc] initWithWidth:UIScreen.mainScreen.bounds.size.width
                                                                   height:UIScreen.mainScreen.bounds.size.height
                                                                      fps:12];
            weakSelf.mediaController.sharingEnabled = YES;
            [weakSelf.collectionView reloadData];
        });
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
    SharingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                  forIndexPath:indexPath];
    [cell setupImageName:self.images[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.bounds.size;
}

@end
