//
//  OpponentCollectionViewCell.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCVideoTrack;
@class CornerView;

// TODO maybe it should be subclass of users table view cell?
@interface OpponentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet CornerView *colorMarker;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) UIView *videoView;

@property (assign, nonatomic) QBRTCConnectionState connectionState;

- (void)setMarkerColor:(UIColor *)color;
- (void)setMarkerText:(NSString *)text;

@end

