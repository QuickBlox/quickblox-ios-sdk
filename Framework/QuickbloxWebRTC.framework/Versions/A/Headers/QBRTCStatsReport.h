//
//  QBRTCStatsBuilder.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 10/11/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBRTCBitrateTracker;

/* Class used to accumulate stats information into a single displayable string.
 * WARNING: experimental feature. Class will be refactored next release.
 */
@interface QBRTCStatsReport : NSObject

#pragma mark Bitrate trackers

/* Bitrate trackers below used to estimate bitrate based on byte count. It is expected that
*  byte count is monotonocially increasing. This class tracks the times that
*  byte count is updated, and measures the bitrate based on the byte difference
*  over the interval between updates.
*/

/// Audio received bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *audioReceivedBitrateTracker;

/// Audio send bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *audioSendBitrateTracker;

/// Connection received bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *connectionReceivedBitrateTracker;

/// Connection send bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *connectionSendBitrateTracker;

/// Video received bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *videoReceivedBitrateTracker;

/// Video send bitrate tracker
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *videoSendBitrateTracker;

#pragma mark Connection stats

/// Total number of bytes received for this connection
@property (nonatomic, copy, readonly) NSString *connectionReceivedBitrate;

/// Total number of bytes send for this connection
@property (nonatomic, copy, readonly) NSString *connectionSendBitrate;

/* Estimated round trip time (ms) for this connection.
 * RTT is the length of time it takes for a signal to be sent plus the length of time it takes for an acknowledgment of that signal to be received.
 */
@property (nonatomic, copy, readonly) NSString *connectionRoundTripTime;

/// Type of local ice candidate e.g. local or relay
@property (nonatomic, copy, readonly) NSString *localCandidateType;

/// Type of remote ice candidate e.g. local or relay
@property (nonatomic, copy, readonly) NSString *remoteCandidateType;

/// Transport type: UDP or TCP. TCP is usually used with TURN server
@property (nonatomic, copy, readonly) NSString *transportType;

// Whether connection is active or not
@property (nonatomic, copy, readonly) NSString *transportConnectionIsActive;

// Check if valid incoming ICE request has been received
@property (nonatomic, copy, readonly) NSString *readableIceRequest;

// Check if valid incoming ICE request has been received and ACK to an ICE request.
@property (nonatomic, copy, readonly) NSString *writableIceRequest;

/// Total number of RTP packets sent for this connection. Calculated as defined in [RFC3550] section 6.4.1.
@property (nonatomic, copy, readonly) NSString *packetsSent;

/// Packets discarded on send
@property (nonatomic, copy, readonly) NSString *packetsDiscardedOnSend;

/// It is a unique identifier that is associated to the object that was inspected to produce the RTCIceCandidateAttributes for the local candidate associated with this candidate pair.
@property (nonatomic, copy, readonly) NSString *localCandidateID;

/// Identifier for the channel. Example: "Channel-audio-1"
@property (nonatomic, copy, readonly) NSString *channelID;

/// Local address with port, example: 192.168.2.45:63061
@property (nonatomic, copy, readonly) NSString *localAddress;

/// Remote address with port, example: 192.168.2.45:63061
@property (nonatomic, copy, readonly) NSString *remoteAddress;

#pragma mark Bandwidth Estimation stats

/// Actual encoding bitrate, bit/s
@property (nonatomic, copy, readonly) NSString *actualEncodingBitrate;

/// How much receive bandwidth we estimate we have, bit/s
@property (nonatomic, copy, readonly) NSString *availableReceiveBandwidth;

/// How much send bandwidth we estimate we have, bit/s
@property (nonatomic, copy, readonly) NSString *availableSendBandwidth;

/// Target encoding bitrate, bit/s
@property (nonatomic, copy, readonly) NSString *targetEncodingBitrate;

/// Bucket delay
@property (nonatomic, copy, readonly) NSString *bucketDelay;

/// Retransmit bitrate, bit/s
@property (nonatomic, copy, readonly) NSString *retransmitBitrate;

/// The actual transmit bitrate, bit/s
@property (nonatomic, copy, readonly) NSString *transmitBitrate;

#pragma mark Video send stats

/// Video packets lost
@property (nonatomic, copy, readonly) NSString *videoSendPacketsLost;

/// Video packets send
@property (nonatomic, copy, readonly) NSString *videoSendPacketsSent;

/// Video send encode usage percent
@property (nonatomic, copy, readonly) NSString *videoSendEncodeUsagePercent;

/// Video send unique identifier
@property (nonatomic, copy, readonly) NSString *videoSendTrackID;

/// Average video encoding time
@property (nonatomic, copy, readonly) NSString *videoSendEncodeMs;

/// Video send input frame rate
@property (nonatomic, copy, readonly) NSString *videoSendInputFps;

/// Video send input height
@property (nonatomic, copy, readonly) NSString *videoSendInputHeight;

/// Video send input width
@property (nonatomic, copy, readonly) NSString *videoSendInputWidth;

/// Video send codec: VP8 or H264
@property (nonatomic, copy, readonly) NSString *videoSendCodec;

/// Video send bitrate
@property (nonatomic, copy, readonly) NSString *videoSendBitrate;

/// Video send frames per second (FPS)
@property (nonatomic, copy, readonly) NSString *videoSendFps;

/// Video send height
@property (nonatomic, copy, readonly) NSString *videoSendHeight;

/// Video send width
@property (nonatomic, copy, readonly) NSString *videoSendWidth;

/// Video send NACKs received
@property (nonatomic, copy, readonly) NSString *videoSendNacksReceived;

/// Video send plis received
@property (nonatomic, copy, readonly) NSString *videoSendPlisReceived;

/// Video send view limited resolution
@property (nonatomic, copy, readonly) NSString *videoSendViewLimitedResolution;

/// Video send cpu limited resolution
@property (nonatomic, copy, readonly) NSString *videoSendCpuLimitedResolution;

#pragma mark Video receive stats

/// Time spent decoding video in ms
@property (nonatomic, copy, readonly) NSString *videoReceivedDecodeMs;

/// Video received decoded frames per second (FPS)
@property (nonatomic, copy, readonly) NSString *videoReceivedDecodedFps;

/* Video received output frames per second (FPS)
 * Real frames per second output, after processing
 **/
@property (nonatomic, copy, readonly) NSString *videoReceivedOutputFps;

/// Video received frames per second (FPS)
@property (nonatomic, copy, readonly) NSString *videoReceivedFps;

/// Video received bitrate
@property (nonatomic, copy, readonly) NSString *videoReceivedBitrate;

/// Video received height
@property (nonatomic, copy, readonly) NSString *videoReceivedHeight;

/// Video received width
@property (nonatomic, copy, readonly) NSString *videoReceivedWidth;

#pragma mark Audio send stats

/// Audio send bitrate
@property (nonatomic, copy, readonly) NSString *audioSendBitrate;

/** Audio send input level
 *  You can use this property even if audio track is disabled
 *  to check if user is currently speaking/talking etc.
 */
@property (nonatomic, copy, readonly) NSString *audioSendInputLevel;

/// As audioSendBitrate, but without any changes or processing
@property (nonatomic, copy, readonly) NSString *audioSendBytesSent;

/// Audio send packets lost
@property (nonatomic, copy, readonly) NSString *audioSendPacketsLost;

/// Audio send packets sent
@property (nonatomic, copy, readonly) NSString *audioSendPacketsSent;

/// Audio send codec: OPUS, ISAC or iLBC
@property (nonatomic, copy, readonly) NSString *audioSendCodec;

/// Audio send track unique identifier
@property (nonatomic, copy, readonly) NSString *audioSendTrackID;

///Receive-side jitter in milliseconds
@property (nonatomic, copy, readonly) NSString *audioSendJitterReceived;

#pragma mark Audio receive stats

/// Audio received current delay, in ms
@property (nonatomic, copy, readonly) NSString *audioReceivedCurrentDelay;

/// Received audio packets lost
@property (nonatomic, copy, readonly) NSString *audioReceivedPacketsLost;

/// Received audio packets number
@property (nonatomic, copy, readonly) NSString *audioReceivedPacketsReceived;

/// Audio received track unique identifier
@property (nonatomic, copy, readonly) NSString *audioReceivedTrackId;

/// The speech expand rate measures the amount of speech expansion done by NetEQ
@property (nonatomic, copy, readonly) NSString *audioReceivedExpandRate;

/// Audio received bitrate, bit/s
@property (nonatomic, copy, readonly) NSString *audioReceivedBitrate;

/// Received audio codec: VP8 or H264
@property (nonatomic, copy, readonly) NSString *audioReceivedCodec;

@end
