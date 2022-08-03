//
//  ParticipantView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParticipantView : UIView
//MARK: - Properties
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *participantId;
@property (assign, nonatomic) QBRTCConnectionState connectionState;
@property (assign, nonatomic) BOOL isCallingInfo;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UILabel *userAvatarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callingInfoLabelHeightConstraint;

- (void)setupViews;
- (void)setupHiddenViews;

@end

NS_ASSUME_NONNULL_END
