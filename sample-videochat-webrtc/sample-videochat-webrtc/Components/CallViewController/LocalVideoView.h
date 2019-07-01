//
//  LocalVideoView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
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
