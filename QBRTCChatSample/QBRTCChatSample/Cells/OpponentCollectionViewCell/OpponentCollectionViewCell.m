//
//  OpponentCollectionViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OpponentCollectionViewCell.h"
#import "CornerView.h"
#import "UserPicView.h"

@interface OpponentCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UserPicView *userPic;
@property (weak, nonatomic) IBOutlet QBGLVideoView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation OpponentCollectionViewCell

- (void)dealloc {
}

- (void)awakeFromNib {
    [super awakeFromNib];

   [self.activityIndicator startAnimating];
    self.statusLabel.text = @"";
    self.userPic.picColor = [UIColor colorWithWhite:0.269 alpha:0.930];
    self.backgroundColor = [UIColor colorWithWhite:0.724 alpha:0.880];
    self.layer.borderWidth = 1.0;
}

- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack {
    
    [self.remoteVideoView setVideoTrack:videoTrack];
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
                [self.activityIndicator stopAnimating];
                break;
                
            case QBRTCConnectionChecking:
                
                self.statusLabel.text = @"Checking";
                [self.activityIndicator startAnimating];
                
                break;
                
            case QBRTCConnectionConnecting:
                
                self.statusLabel.text = @"Connecting";
                [self.activityIndicator startAnimating];
                
                break;
                
            case QBRTCConnectionConnected:
                
                self.statusLabel.text = @"Connected";
                [self.activityIndicator stopAnimating];
                
                break;
                
            case QBRTCConnectionHangUp:
                
                self.statusLabel.text = @"Hung Up";
                [self.activityIndicator stopAnimating];
                
                break;
                
            case QBRTCConnectionRejected:
                
                self.statusLabel.text = @"Rejected";
                [self.activityIndicator stopAnimating];
                
                break;
                
            case QBRTCConnectionNoAnswer:
                
                self.statusLabel.text = @"No Answer";
                [self.activityIndicator stopAnimating];
                
                break;
                
            case QBRTCConnectionDisconnectTimeout:
                
                self.statusLabel.text = @"Time out";
                [self.activityIndicator stopAnimating];
                
                break;
                
            case QBRTCConnectionDisconnected:
                
                self.statusLabel.text = @"Disconnected";
                [self.activityIndicator startAnimating];
                
                break;
            default:
                break;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        
        self.layer.borderColor = [UIColor colorWithRed:0.397 green:0.405 blue:0.368 alpha:1.000].CGColor;
        
    }
    else {
        self.layer.borderColor = [UIColor colorWithRed:1.000 green:0.970 blue:0.995 alpha:0.600].CGColor;
    }
}

@end
