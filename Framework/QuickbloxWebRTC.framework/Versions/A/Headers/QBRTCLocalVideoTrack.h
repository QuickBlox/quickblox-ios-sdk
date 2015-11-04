//
//  QBRTCLocalVideoTrack.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 20/10/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

@class QBRTCVideoCapture;

@interface QBRTCLocalVideoTrack : QBRTCMediaStreamTrack

@property (nonatomic, weak) QBRTCVideoCapture *videoCapture;

/// Init is not a supported initializer for this class
- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));


@end