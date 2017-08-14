//
//  QBRTCLocalVideoTrack.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCMediaStreamTrack.h"

@class QBRTCVideoCapture;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCLocalVideoTrack class interface.
 *  This class represents local video track.
 */
@interface QBRTCLocalVideoTrack : QBRTCMediaStreamTrack

/**
 *  Video capture instance.
 */
@property (weak, nonatomic, nullable) QBRTCVideoCapture *videoCapture;

@end

NS_ASSUME_NONNULL_END
