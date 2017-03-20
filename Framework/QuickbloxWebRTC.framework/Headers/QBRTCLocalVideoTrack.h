//
//  QBRTCLocalVideoTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCMediaStreamTrack.h"

@class QBRTCVideoCapture;

NS_ASSUME_NONNULL_BEGIN

@interface QBRTCLocalVideoTrack : QBRTCMediaStreamTrack

@property (nonatomic, weak) QBRTCVideoCapture *videoCapture;

/// Init is not a supported initializer for this class
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
