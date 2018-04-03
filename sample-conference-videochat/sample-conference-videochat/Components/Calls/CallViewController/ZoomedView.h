//
//  ZoomedView.h
//  sample-multiconference-videochat
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomedView : UIView

@property (weak, nonatomic) UIView *videoView;
@property (copy, nonatomic) void (^didTapView)(ZoomedView *zoomedView);

@end
