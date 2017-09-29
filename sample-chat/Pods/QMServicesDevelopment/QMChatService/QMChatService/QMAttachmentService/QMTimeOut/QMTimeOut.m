//
//  QMTimeOut.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMTimeOut.h"

@interface QMTimeOut() {
    dispatch_queue_t timeoutQueue;
    dispatch_source_t timeoutTimer;
    void *timeoutQueueTag;
}

@property (nonatomic, assign, readwrite) NSTimeInterval timeInterval;

@end

@implementation QMTimeOut

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                               queue:(dispatch_queue_t)queue {
    
    if (self = [super init]) {
        
        _timeInterval = timeInterval;
        timeoutQueueTag = &timeoutQueueTag;
        
        if (!queue) {
            timeoutQueue = dispatch_queue_create("QM.QMTimeOut", DISPATCH_QUEUE_SERIAL);
        }
        else {
            timeoutQueue = queue;
        }
        
        dispatch_queue_set_specific(timeoutQueue, timeoutQueueTag, timeoutQueueTag, NULL);
    }
    
    return self;
}

- (void)startWithFireBlock:(dispatch_block_t)fireBlock {
    
    if (_timeInterval >= 0.0 && !timeoutTimer)
    { 
        timeoutTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timeoutQueue);
        
        dispatch_source_set_event_handler(timeoutTimer, ^{ @autoreleasepool {
            
            fireBlock();
        }});
        
        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (_timeInterval * NSEC_PER_SEC));
        dispatch_source_set_timer(timeoutTimer, tt, DISPATCH_TIME_FOREVER, 0);
        
        dispatch_resume(timeoutTimer);
    }
}

- (void)cancelTimeout {
    
    if (timeoutTimer) {
        dispatch_source_cancel(timeoutTimer);
        timeoutTimer = NULL;
    }
}

- (void)dealloc {
    [self cancelTimeout];
}


@end
