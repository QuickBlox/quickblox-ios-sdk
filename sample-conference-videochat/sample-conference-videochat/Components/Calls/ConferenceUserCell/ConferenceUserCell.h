//
//  OpponentCollectionViewCell.h
//  sample-conference-videochat
//
//  Created by Injoit on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCVideoTrack;

@interface ConferenceUserCell : UICollectionViewCell

@property (weak, nonatomic) UIView *videoView;

/**
 *  Mute user block action.
 */
@property (copy, nonatomic) void (^didChangeVideoGravity)(BOOL isResizeAspect);
@property (assign, nonatomic) BOOL isResizeAspect;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIColor *nameColor;
@property (assign,nonatomic) BOOL isMuted;
@property (assign, nonatomic) BOOL videoEnabled;

@end
