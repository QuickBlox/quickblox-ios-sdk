//
//  LocalVideoView.m
//  sample-conference-videochat
//
//  Created by Injoit on 12/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "LocalVideoView.h"

@interface LocalVideoView()

@property (weak, nonatomic) AVCaptureVideoPreviewLayer *videoLayer;
@property (strong, nonatomic) UIView *containerView;

@end

@implementation LocalVideoView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPreviewlayer:(AVCaptureVideoPreviewLayer *)layer {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.videoLayer = layer;
        self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerView.backgroundColor = [UIColor clearColor];
        [self insertSubview:self.containerView atIndex:0];
        [self.containerView.layer insertSublayer:layer atIndex:0];
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
