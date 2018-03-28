//
//  OpponentCollectionViewCell.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCVideoTrack;

@interface OpponentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) UIView *videoView;

/**
 *  Mute user block action.
 */
@property (copy, nonatomic) void (^didPressMuteButton)(BOOL isMuted);

@property (assign, nonatomic) QBRTCConnectionState connectionState;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) UIColor *nameColor;
@property (copy, nonatomic) NSString *bitrateString;

@end
