//
//  LocalVideoView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "LocalVideoView.h"

@interface LocalVideoView()
//MARK: - Properties
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *videoLayer;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation LocalVideoView
//MARK: - Life Cycle
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPreviewlayer:(AVCaptureVideoPreviewLayer *)layer {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.videoLayer = layer;
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerView.backgroundColor = [UIColor clearColor];
        [self.containerView.layer insertSublayer:self.videoLayer atIndex:0];
        
        [self insertSubview:self.containerView atIndex:0];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self updateOrientationIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = self.bounds;
    self.videoLayer.frame = self.bounds;
}

//MARK: - Private Methods
- (void)updateConstraints {
    [super updateConstraints];
    self.containerView.frame = self.bounds;
    self.videoLayer.frame = self.bounds;
    
}

- (void)updateOrientationIfNeeded {
    AVCaptureConnection *previewLayerConnection = self.videoLayer.connection;
    UIInterfaceOrientation interfaceOrientation = UIApplication.sharedApplication.windows.firstObject.windowScene.interfaceOrientation;
    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)interfaceOrientation;
    
    BOOL isVideoOrientationSupported = [previewLayerConnection isVideoOrientationSupported];
    if (isVideoOrientationSupported
        && previewLayerConnection.videoOrientation != videoOrientation) {
        [previewLayerConnection setVideoOrientation:videoOrientation];
    }
}

@end
