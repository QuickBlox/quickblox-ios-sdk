//
//  QBRTCMediaStreamTrack.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 20/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Base class to describe class with media information
 */
@interface QBRTCMediaStreamTrack : NSObject

/// Enable or disable track for a stream
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
