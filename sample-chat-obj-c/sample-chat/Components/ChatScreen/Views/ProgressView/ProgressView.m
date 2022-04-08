//
//  ProgressView.m
//  sample-chat
//
//  Created by Injoit on 17.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "ProgressView.h"
#import "UIView+Chat.h"

@interface ProgressView()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ProgressView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setRoundViewWithCornerRadius:16.0f];
}

- (BOOL)isRunning {
    return self.activityIndicator.isAnimating;
}

- (void)start {
    if ([self isRunning]) {
        return;
    }
    UIWindow *lastWindow = UIApplication.sharedApplication.windows.lastObject;
    [lastWindow addSubview:self];
    self.center = lastWindow.center;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self removeFromSuperview];
    });
}

@end
