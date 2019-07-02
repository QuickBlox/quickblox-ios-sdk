//
//  OpponentCollectionViewCell.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCVideoTrack;

@interface OpponentCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) UIView *videoView;

/**
 *  Mute user block action.
 */
@property (copy, nonatomic) void (^didPressMuteButton)(BOOL isMuted);

@property (assign, nonatomic) QBRTCConnectionState connectionState;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIColor *nameColor;
@property (copy, nonatomic) NSString *bitrateString;
@property (copy, nonatomic) NSString *statusString;

@end
