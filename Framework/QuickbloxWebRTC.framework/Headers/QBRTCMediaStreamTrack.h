//
//  QBRTCMediaStreamTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Base class to describe class with media information
 */
@interface QBRTCMediaStreamTrack : NSObject

/// Enable or disable track for a stream
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
