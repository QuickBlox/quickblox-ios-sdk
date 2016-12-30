//
//  LocalVideoView.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 12/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "LocalVideoView.h"

@interface LocalVideoView()

@property (weak, nonatomic) AVCaptureVideoPreviewLayer *videoLayer;
@property (strong, nonatomic) UIButton *switchCameraBtn;
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
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        UIImage *image = [UIImage imageNamed:@"switchCamera"];
        
        self.switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchCameraBtn.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin);
        [self.switchCameraBtn setImage:image
                              forState:UIControlStateNormal];
        
        [self.switchCameraBtn addTarget:self
                                 action:@selector(didPressSwitchCamera:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        self.containerView = [[UIView alloc] initWithFrame:self.bounds];
        self.containerView.backgroundColor = [UIColor clearColor];
        [self.containerView.layer insertSublayer:layer atIndex:0];
        
        [self insertSubview:self.containerView atIndex:0];
        [self addSubview:self.switchCameraBtn];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self updateOrientationIfNeeded];
}

- (void)didPressSwitchCamera:(UIButton *)sender {
    
    [self.delegate localVideoView:self pressedSwitchButton:sender];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    self.containerView.frame = self.bounds;
    self.videoLayer.frame = self.bounds;
    
    CGSize buttonSize = CGSizeMake(72 / 2.5, 54 / 2.5);
    self.switchCameraBtn.frame = CGRectMake(self.bounds.size.width - buttonSize.width -5,
                                            self.bounds.size.height - buttonSize.height - 30,
                                            buttonSize.width,
                                            buttonSize.height);
}

- (void)updateOrientationIfNeeded {
    
    AVCaptureConnection *previewLayerConnection = self.videoLayer.connection;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)interfaceOrientation;
    
    BOOL isVideoOrientationSupported = [previewLayerConnection isVideoOrientationSupported];
    if (isVideoOrientationSupported
        && previewLayerConnection.videoOrientation != videoOrientation) {
        [previewLayerConnection setVideoOrientation:videoOrientation];
    }
}

@end
