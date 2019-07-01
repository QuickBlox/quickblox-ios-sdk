//
//  ZoomedView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomedView : UIView

@property (weak, nonatomic) UIView *videoView;
@property (copy, nonatomic) void (^didTapView)(ZoomedView *zoomedView);

@end
