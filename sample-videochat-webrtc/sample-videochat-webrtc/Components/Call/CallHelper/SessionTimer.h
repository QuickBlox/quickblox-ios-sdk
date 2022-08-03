//
//  WaitSession.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SessionTimerType) {
    SessionTimerTypeActive,
    SessionTimerTypeActions,
    SessionTimerTypeAccept,
    SessionTimerTypeConnected
};

@protocol SessionTimerDelegate;

@interface SessionTimer : NSObject

@property (nonatomic, assign, readonly) SessionTimerType type;
@property (nonatomic, strong, readonly) NSString *sessionId;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *userInfo;

@property (nonatomic, weak) id<SessionTimerDelegate> delegate;

+ (id)waitSession:(NSString *)sessionId type:(SessionTimerType)type waitingTime:(NSTimeInterval)time;

- (id)initWithSession:(NSString *)sessionId
                   type:(SessionTimerType)type
               waitingTime:(NSTimeInterval)time;

- (instancetype)init NS_UNAVAILABLE;

- (void)invalidate;


@end

@protocol SessionTimerDelegate <NSObject>

- (void)timerDidEndWaiting:(SessionTimer *)timer;

@end

NS_ASSUME_NONNULL_END
