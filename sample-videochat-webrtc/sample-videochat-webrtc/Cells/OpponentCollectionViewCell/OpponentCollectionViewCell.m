//
//  OpponentCollectionViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OpponentCollectionViewCell.h"
#import "CornerView.h"

@interface OpponentCollectionViewCell()

@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation OpponentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor blackColor];
    self.statusLabel.backgroundColor =
    [UIColor colorWithRed:0.9441 green:0.9441 blue:0.9441 alpha:0.350031672297297];
    self.statusLabel.text = @"";
}

- (void)setVideoView:(UIView *)videoView {
    
    if (_videoView != videoView) {

        [_videoView removeFromSuperview];
        _videoView = videoView;
        _videoView.frame = self.bounds;
        [self.containerView insertSubview:_videoView aboveSubview:self.statusLabel];
    }
}

- (void)setColorMarkerText:(NSString *)text andColor:(UIColor *)color {
    
    self.colorMarker.bgColor = color;
    self.colorMarker.title = text;
}

- (void)setConnectionState:(QBRTCConnectionState)connectionState {
    
    if (_connectionState != connectionState) {
        _connectionState = connectionState;
        
        switch (connectionState) {
                
            case QBRTCConnectionNew:
                
                self.statusLabel.text = @"New";
                
                break;
                
            case QBRTCConnectionPending:
                
                self.statusLabel.text = @"Pending";
                
                break;
                
            case QBRTCConnectionChecking:
                
                self.statusLabel.text = @"Checking";
    
                break;
                
            case QBRTCConnectionConnecting:
                
                self.statusLabel.text = @"Connecting";
                
                break;
                
            case QBRTCConnectionConnected:
                
                self.statusLabel.text = @"Connected";
                
                break;
                
            case QBRTCConnectionClosed:
                
                self.statusLabel.text = @"Closed";
                
                break;
                
            case QBRTCConnectionHangUp:
                
                self.statusLabel.text = @"Hung Up";
                
                break;
                
            case QBRTCConnectionRejected:
                
                self.statusLabel.text = @"Rejected";
                
                break;
                
            case QBRTCConnectionNoAnswer:
                
                self.statusLabel.text = @"No Answer";
                
                break;
                
            case QBRTCConnectionDisconnectTimeout:
                
                self.statusLabel.text = @"Time out";
                
                break;
                
            case QBRTCConnectionDisconnected:
                
                self.statusLabel.text = @"Disconnected";
                
                break;
            default:
                break;
        }
    }
}

@end
