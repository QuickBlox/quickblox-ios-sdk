//
//  QBRTCTimer.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Background Timer class used to allow running tasks in background
 *  call this method when you enter background state
 */
@interface QBRTCTimer : NSObject

/// Timer identification
@property (copy, nonatomic) NSString *label;

/// Shows whether timer is running or stopped
@property (assign, nonatomic, readonly) BOOL isValid;

/**
 *  Initializing background timer
 *
 *  @param timeInterval task running time
 *  @param repeat       repeat timer execution or run it only once
 *  @param queue        queue on which timer will be started
 *  @param completion   completion block called when timer has been started
 *  @param expiration   expiration handler, called when task is to expire its running time
 *
 *  @return QBRTCTimer instance
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
							  repeat:(BOOL)repeat
							   queue:(dispatch_queue_t)queue
						  completion:(dispatch_block_t)completion
						  expiration:(dispatch_block_t)expiration;

/// Start timer
- (void)start;

/// Stop timer
- (void)invalidate;

/// Remaining time for current task
- (NSTimeInterval)remainingTime;

@end

NS_ASSUME_NONNULL_END
