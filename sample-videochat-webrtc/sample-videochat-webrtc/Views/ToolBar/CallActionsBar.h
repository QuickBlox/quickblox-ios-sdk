//
//  ToolBar.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CallActionType) {
    CallActionAudio,
    CallActionVideo,
    CallActionSpeaker,
    CallActionDecline,
    CallActionShare,
    CallActionSwitchCamera
};

@interface ToolBar : UIToolbar

- (void)addButton:(UIButton *)button action:(void(^)(UIButton *sender))action;

- (void)updateItems;
- (void)removeAllButtons;

@end
