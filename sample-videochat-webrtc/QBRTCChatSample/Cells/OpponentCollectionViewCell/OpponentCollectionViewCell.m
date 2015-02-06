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
@property (weak, nonatomic) QBRTCVideoTrack *videoTrack;

@end

@implementation OpponentCollectionViewCell

- (void)dealloc {
}

- (void)awakeFromNib {
    [super awakeFromNib];

   [self.activityIndicator startAnimating];
}

- (void)setVideoTrack:(QBRTCVideoTrack *)videoTrack {
    
    if (_videoTrack != videoTrack) {
        
        _videoTrack = videoTrack;
        
        [self.remoteVideoView setVideoTrack:videoTrack];
    }
}

- (void)setColorMarkerText:(NSString *)text andColor:(UIColor *)color {
    
    self.colorMarker.bgColor = color;
    self.colorMarker.title = text;
}

- (void)setConnected:(BOOL)connected {
    
    if (_connected != connected) {
        
        _connected = connected;
        
        if (connected) {
         
            [self.activityIndicator stopAnimating];
        }
        else {
            
            [self.activityIndicator startAnimating];
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.userPic.backgroundColor = [self.colorMarker.bgColor colorWithAlphaComponent:0.3];
    
    if (selected) {
        
        self.layer.borderColor = self.colorMarker.bgColor.CGColor;
        self.layer.borderWidth = 1.0;
    }
    else {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0;
    }
}

@end
