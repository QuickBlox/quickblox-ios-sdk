//
//  CallActionsBar.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CallAction;

typedef NS_ENUM(NSInteger, CallActionType) {
    CallActionAudio = 0,
    CallActionVideo,
    CallActionSpeaker,
    CallActionDecline,
    CallActionShare,
    CallActionSwitchCamera
};

@interface CallActionsBar : UIToolbar
- (void)clear;
- (void)setupWithActions:(NSArray<CallAction *> *)actions;
- (void)select:(BOOL)selected type:(CallActionType)type;
- (BOOL)isSelected:(CallActionType)type;
- (void)setUserInteractionEnabled:(BOOL)enabled type:(CallActionType)type;
@end

NS_ASSUME_NONNULL_END
