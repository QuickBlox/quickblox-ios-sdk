//
//  LocalVideoView.h
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 12/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocalVideoViewDelegate;

@interface LocalVideoView : UIView

@property (weak, nonatomic) id <LocalVideoViewDelegate>delegate;
- (instancetype)initWithPreviewlayer:(AVCaptureVideoPreviewLayer *)layer;

@end

@protocol LocalVideoViewDelegate <NSObject>

- (void)localVideoView:(LocalVideoView *)localVideoView pressedSwitchButton:(UIButton *)sender;

@end
