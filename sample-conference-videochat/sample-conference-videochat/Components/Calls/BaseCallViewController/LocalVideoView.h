//
//  LocalVideoView.h
//  sample-conference-videochat
//
//  Created by Injoit on 12/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalVideoView : UIView
- (instancetype)initWithPreviewlayer:(AVCaptureVideoPreviewLayer *)layer;
@end
