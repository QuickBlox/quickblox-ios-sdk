//
//  ZoomedView.h
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 6/21/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomedView : UIView

@property (weak, nonatomic) UIView *videoView;
@property (copy, nonatomic) void (^didTapView)(ZoomedView *zoomedView);

@end
