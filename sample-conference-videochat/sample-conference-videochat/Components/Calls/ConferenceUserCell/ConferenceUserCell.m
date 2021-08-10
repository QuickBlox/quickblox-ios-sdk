//
//  OpponentCollectionViewCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "ConferenceUserCell.h"
#import "UILabel+Chat.h"
#import "UIView+Chat.h"
#import "NSString+Chat.h"

@interface ConferenceUserCell()
@property (weak, nonatomic) IBOutlet UILabel *userNameTopLabel;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UILabel *userAvatarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *unmuteImageView;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *unmuteOnVideoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unmuteImageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelCenterXConstraint;

@end

@implementation ConferenceUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.isResizeAspect = YES;
    self.videoEnabled = YES;
    self.isMuted = NO;
    self.nameColor = UIColor.clearColor;
    self.backgroundColor = UIColor.clearColor;
    self.videoContainerView.backgroundColor = UIColor.clearColor;
    self.containerView.backgroundColor = [UIColor colorWithRed:0.20f green:0.20f blue:0.20f alpha:1.0f];
    [self.userAvatarLabel setRoundedLabelWithCornerRadius:30.0f];
    [self.userAvatarImageView setRoundViewWithCornerRadius:30.0f];
    self.userAvatarImageView.hidden = YES;
    self.videoContainerView.hidden = NO;
    self.unmuteOnVideoImageView.hidden = YES;
    self.nameLabelCenterXConstraint.constant = 0.0f;
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.videoContainerView addGestureRecognizer:pinchGesture];
}

- (void)setIsResizeAspect:(BOOL)isResizeAspect {
    if (_isResizeAspect != isResizeAspect) {
        _isResizeAspect = isResizeAspect;
        if (self.didChangeVideoGravity) {
             self.didChangeVideoGravity(isResizeAspect);
        }
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view != nil) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            CGFloat currentScale = self.videoContainerView.frame.size.width / self.videoContainerView.bounds.size.width;
            CGFloat newScale = currentScale * gestureRecognizer.scale;
            if (self.isResizeAspect == YES) {
                if (newScale < currentScale) {
                    self.isResizeAspect = NO;
                }
            } else {
                if (newScale > currentScale) {
                    self.isResizeAspect = YES;
                }
            }
        }
    }
}

- (void)setVideoView:(UIView *)videoView {
    
    _videoView = videoView;
    
    [self.videoContainerView insertSubview:videoView atIndex:0];
        
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [videoView.leftAnchor constraintEqualToAnchor:self.videoContainerView.leftAnchor].active = YES;
    [videoView.rightAnchor constraintEqualToAnchor:self.videoContainerView.rightAnchor].active = YES;
    [videoView.topAnchor constraintEqualToAnchor:self.videoContainerView.topAnchor].active = YES;
    [videoView.bottomAnchor constraintEqualToAnchor:self.videoContainerView.bottomAnchor].active = YES;
    
    [videoView layoutIfNeeded];
}

- (void)setName:(NSString *)name {
    if (!name) {
        return;
    }
    if (![_name isEqualToString:name]) {
        _name = [name copy];
        
        self.userNameTopLabel.text = self.name;
        self.nameLabel.text = self.name;
        self.userAvatarLabel.text = name.firstLetter;
    }
}

- (void)setNameColor:(UIColor *)nameColor {
    if (![_nameColor isEqual:nameColor]) {
        _nameColor = nameColor;
        self.userAvatarLabel.backgroundColor = nameColor;
    }
}

- (void)setIsMuted:(BOOL)isMuted {
    if (_isMuted != isMuted) {
        _isMuted = isMuted;
        self.unmuteImageViewWidthConstraint.constant = isMuted ? 0.0f : 40.0f;
        self.nameLabelCenterXConstraint.constant = isMuted ? 0.0f : -10.0f;
        self.unmuteOnVideoImageView.hidden = isMuted;
    }
}

@end
