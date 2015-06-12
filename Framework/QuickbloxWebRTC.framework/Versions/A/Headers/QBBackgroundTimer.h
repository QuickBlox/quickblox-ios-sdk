//
//  QBBackgroundTimer.h
//  QBRTCChatSample
//
//  Created by Andrey Ivanov on 30.03.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBBackgroundTimer : NSObject

@property (strong, nonatomic, readonly) NSTimer *timer;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initAndSheduleWithTimeInterval:(NSTimeInterval)timeInterval
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)yesNo
                                  timerDidFire:(dispatch_block_t)timerDidFire
                             expirationHandler:(dispatch_block_t)expirationHandler;

- (void)invalidate;

@end
