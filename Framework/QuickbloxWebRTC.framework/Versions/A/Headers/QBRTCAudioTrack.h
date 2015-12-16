//
//  QBRTCAudioTrack.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 05/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

/// Entity to describe remote audio track
@interface QBRTCAudioTrack : QBRTCMediaStreamTrack

/// Init is not a supported initializer for this class.
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
