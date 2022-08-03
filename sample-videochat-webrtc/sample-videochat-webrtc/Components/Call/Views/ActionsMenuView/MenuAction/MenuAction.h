//
//  MenuAction.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UserAction) {
    UserActionNone = 0,
    UserActionSelectParticipant,
    UserActionUserProfile,
    UserActionLogout,
    UserActionAppInfo,
    UserActionAudioConfig,
    UserActionVideoConfig
};

typedef void(^MenuActionHandler)(UserAction action);

@interface MenuAction : NSObject
//MARK: - Properties
@property (strong, nonatomic, readonly) NSString *title;
@property (assign, nonatomic, readonly) UserAction action;
@property (assign, nonatomic, readonly) BOOL isSelected;
@property (strong, nonatomic, readonly) MenuActionHandler handler;

- (instancetype)initWithTitle:(NSString *)title isSelected:(BOOL)isSelected action:(UserAction)action handler:(MenuActionHandler _Nullable)handler;

@end

NS_ASSUME_NONNULL_END
