//
//  QBRTCBitrateTracker.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Class used to estimate bitrate based on byte count. It is expected that
 *  byte count is monotonocially increasing. This class tracks the times that
 *  byte count is updated, and measures the bitrate based on the byte difference
 *  over the interval between updates.
 */
@interface QBRTCBitrateTracker : NSObject

/** The bitrate in bits per second. */
@property (nonatomic, readonly) double bitrate;
/** The bitrate as a formatted string in bps, Kbps or Mbps. */
@property (nonatomic, readonly) NSString *bitrateString;

/** Converts the bitrate to a readable format in bps, Kbps or Mbps. */
+ (NSString *)bitrateStringForBitrate:(double)bitrate;
/** Updates the tracked bitrate with the new byte count. */
- (void)updateBitrateWithCurrentByteCount:(NSInteger)byteCount;

@end

NS_ASSUME_NONNULL_END
