//
//  OpponentCollectionViewCell.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "OpponentCollectionViewCell.h"
#import "CornerView.h"

static UIImage *unmutedImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"ic-qm-videocall-dynamic-off"];
    });
    return image;
}

static UIImage *mutedImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"ic-qm-videocall-dynamic-on"];
    });
    return image;
}

@interface OpponentCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;

@end

@implementation OpponentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];
    self.bitrateLabel.backgroundColor =
    [UIColor colorWithRed:0.9441 green:0.9441 blue:0.9441 alpha:0.350031672297297];
    self.bitrateLabel.text = @"";
    self.statusLabel.text = @"";
    
    [self.muteButton setImage:unmutedImage() forState:UIControlStateNormal];
    [self.muteButton setImage:mutedImage() forState:UIControlStateSelected];
    self.muteButton.hidden = YES;
    self.muteButton.selected = NO;
}

- (void)setVideoView:(UIView *)videoView {
  
    [self.containerView insertSubview:videoView atIndex:0];
        
    videoView.translatesAutoresizingMaskIntoConstraints = NO;
    [videoView.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor].active = YES;
    [videoView.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor].active = YES;
    [videoView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [videoView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
}

- (void)setName:(NSString *)name {
    
    if (![_name isEqualToString:name]) {
        
        _name = [name copy];
        self.nameLabel.text = _name;
        self.nameView.hidden = _name == nil;
        self.muteButton.hidden = _name == nil;
    }
}

- (void)setNameColor:(UIColor *)nameColor {
    
    if (![_nameColor isEqual:nameColor]) {
        
        _nameColor = nameColor;
        self.nameView.backgroundColor = nameColor;
    }
}

- (void)setConnectionState:(QBRTCConnectionState)connectionState {
    
    if (_connectionState != connectionState) {
        _connectionState = connectionState;
        
        switch (connectionState) {
                
            case QBRTCConnectionStateNew:
                self.statusLabel.text = @"New";
                break;
                
            case QBRTCConnectionStatePending:
                self.statusLabel.text = @"Pending";
                break;
                
            case QBRTCConnectionStateChecking:
            case QBRTCConnectionStateConnecting:
                self.statusLabel.text = @"Connecting";
                break;
                
            case QBRTCConnectionStateConnected:
                self.statusLabel.text = @"Connected";
                break;
                
            case QBRTCConnectionStateClosed:
                self.statusLabel.text = @"Closed";
                break;
                
            case QBRTCConnectionStateFailed:
                self.statusLabel.text = @"Failed";
                break;
                
            case QBRTCConnectionStateHangUp:
                self.statusLabel.text = @"Hung Up";
                break;
                
            case QBRTCConnectionStateRejected:
                self.statusLabel.text = @"Rejected";
                break;
                
            case QBRTCConnectionStateNoAnswer:
                self.statusLabel.text = @"No Answer";
                break;
                
            case QBRTCConnectionStateDisconnectTimeout:
                self.statusLabel.text = @"Time out";
                break;
                
            case QBRTCConnectionStateDisconnected:
                self.statusLabel.text = @"Disconnected";
                break;
                
            case QBRTCConnectionStateUnknown:
                self.statusLabel.text = @"";
                break;
                
            default:
                break;
        }
        
        self.muteButton.hidden = !(connectionState == QBRTCConnectionStateConnected);
    }
}

// MARK: Bitrate

- (void)setBitrateString:(NSString *)bitrateString {
    if (![_bitrateString isEqualToString:bitrateString]) {
        _bitrateString = [bitrateString copy];
        self.bitrateLabel.text = bitrateString;
    }
}

// MARK: Mute button

- (IBAction)didPressMuteButton:(UIButton *)sender {

    sender.selected ^= 1;
    if (self.didPressMuteButton != nil) {
        self.didPressMuteButton(sender.isSelected);
    }
}

@end
