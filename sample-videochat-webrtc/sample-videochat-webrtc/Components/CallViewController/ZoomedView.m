//
//  ZoomedView.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

#import "ZoomedView.h"

@implementation ZoomedView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0f];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(didReceiveTap:)]];
    }
    return self;
}

- (void)setVideoView:(UIView *)videoView {
    
    if (_videoView != videoView) {
        _videoView = videoView;
        [videoView removeFromSuperview];
        videoView.frame = self.bounds;
        videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:videoView];
    }
}

- (void)didReceiveTap:(UITapGestureRecognizer *)__unused gestureRecognizer {
    if (self.didTapView != nil) {
        self.didTapView(self);
    }
}

@end
