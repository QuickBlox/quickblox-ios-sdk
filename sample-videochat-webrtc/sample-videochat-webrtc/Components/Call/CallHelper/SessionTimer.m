//
//  WaitSession.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 26.05.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import "SessionTimer.h"

@interface SessionTimer ()

@property (nonatomic, assign) SessionTimerType type;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SessionTimer

+ (id)waitSession:(NSString *)sessionId
             type:(SessionTimerType)type
      waitingTime:(NSTimeInterval)time {
    return [[SessionTimer alloc] initWithSession:sessionId
                                            type:type
                                     waitingTime:time];
}

- (id)initWithSession:(NSString *)sessionId
                 type:(SessionTimerType)type
          waitingTime:(NSTimeInterval)time {
    self = [super init];
    if (self) {
        self.type = type;
        self.sessionId = sessionId;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:time
          target:self
        selector:@selector(didEndWaiting:)
        userInfo:nil
         repeats:NO];
    }
    
    return self;
}

- (void)invalidate {
    [self.timer invalidate];
}

//MARK: Internal
- (void)didEndWaiting:(NSTimer *)sender {
    if ([self.delegate respondsToSelector:@selector(timerDidEndWaiting:)]) {
        [self.delegate timerDidEndWaiting:self];
    }
}

@end
