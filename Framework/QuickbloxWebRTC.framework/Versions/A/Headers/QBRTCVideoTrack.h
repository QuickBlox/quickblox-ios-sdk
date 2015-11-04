//
//  QBWebRTCVideoTrack.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 13.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

/// Entity to describe video track class
@interface QBRTCVideoTrack : QBRTCMediaStreamTrack

/// Init is not a supported initializer for this class.
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
