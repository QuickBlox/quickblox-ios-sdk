//
//  QBRTCMediaStreamTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCMediaStreamTrack class interface.
 *  Base class to describe class with media information.
 */
@interface QBRTCMediaStreamTrack : NSObject

/**
 *  Media track user ID.
 *
 *  @note nil for local
 */
@property (strong, nonatomic, readonly, nullable) NSNumber *userID;

/**
 *  Determines whether track is enabled or disabled for stream.
 */
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
