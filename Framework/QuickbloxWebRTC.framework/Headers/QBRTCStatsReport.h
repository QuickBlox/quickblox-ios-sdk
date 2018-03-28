//
//  QBRTCStatsBuilder.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QBRTCBitrateTracker;

/**
 QBRTCStatsReport class interface.
 This class represents stats for calls.
 */
@interface QBRTCStatsReport : NSObject

// MARK: Bitrate trackers

/**
 Bitrate trackers below used to estimate bitrate based on byte count. It is expected that
 byte count is monotonocially increasing. This class tracks the times that
 byte count is updated, and measures the bitrate based on the byte difference
 over the interval between updates.
*/

/**
 Audio received bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *audioReceivedBitrateTracker;

/**
 Audio send bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *audioSendBitrateTracker;

/**
 Connection received bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *connectionReceivedBitrateTracker;

/**
 Connection send bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *connectionSendBitrateTracker;

/**
 Video received bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *videoReceivedBitrateTracker;

/**
 Video send bitrate tracker
 */
@property (nonatomic, strong, readonly) QBRTCBitrateTracker *videoSendBitrateTracker;

// MARK: Connection stats

/**
 Total number of bytes received for this connection
 */
@property (nonatomic, readonly, nullable) NSString *connectionReceivedBitrate;

/**
 Total number of bytes send for this connection
 */
@property (nonatomic, readonly, nullable) NSString *connectionSendBitrate;

/**
 Estimated round trip time (ms) for this connection.
 RTT is the length of time it takes for a signal to be sent plus the length of time it takes for an acknowledgment of that signal to be received.
 */
@property (nonatomic, readonly, nullable) NSString *connectionRoundTripTime;

/**
 Type of local ice candidate e.g. local or relay
 */
@property (nonatomic, readonly, nullable) NSString *localCandidateType;

/**
 Type of remote ice candidate e.g. local or relay
 */
@property (nonatomic, readonly, nullable) NSString *remoteCandidateType;

/**
 Transport type: UDP or TCP. TCP is usually used with TURN server
 */
@property (nonatomic, readonly, nullable) NSString *transportType;

/**
 Whether connection is active or not
 */
@property (nonatomic, readonly, nullable) NSString *transportConnectionIsActive;

/**
 Check if valid incoming ICE request has been received
 */
@property (nonatomic, readonly, nullable) NSString *readableIceRequest;

/**
 Check if valid incoming ICE request has been received and ACK to an ICE request.
 */
@property (nonatomic, readonly, nullable) NSString *writableIceRequest;

/**
 Total number of RTP packets sent for this connection. Calculated as defined in [RFC3550] section 6.4.1.
 */
@property (nonatomic, readonly, nullable) NSString *packetsSent;

/**
 Packets discarded on send
 */
@property (nonatomic, readonly, nullable) NSString *packetsDiscardedOnSend;

/**
 It is an unique identifier that is associated to the object that was inspected to produce the RTCIceCandidateAttributes for the local candidate associated with this candidate pair.
 */
@property (nonatomic, readonly, nullable) NSString *localCandidateID;

/**
 Identifier for the channel. Example: "Channel-audio-1"
 */
@property (nonatomic, readonly, nullable) NSString *channelID;

/**
 Local address with port, example: 192.168.2.45:63061
 */
@property (nonatomic, readonly, nullable) NSString *localAddress;

/**
 Remote address with port, example: 192.168.2.45:63061
 */
@property (nonatomic, readonly, nullable) NSString *remoteAddress;

// MARK: Bandwidth Estimation stats

/**
 Actual encoding bitrate, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *actualEncodingBitrate;

/**
 How much receive bandwidth we estimate we have, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *availableReceiveBandwidth;

/**
 How much send bandwidth we estimate we have, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *availableSendBandwidth;

/**
 Target encoding bitrate, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *targetEncodingBitrate;

/**
 Bucket delay
 */
@property (nonatomic, readonly, nullable) NSString *bucketDelay;

/**
 Retransmit bitrate, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *retransmitBitrate;

/**
 The actual transmit bitrate, bit/s
 */
@property (nonatomic, readonly, nullable) NSString *transmitBitrate;

// MARK: Video send stats

/**
 Video packets lost
 */
@property (nonatomic, readonly, nullable) NSString *videoSendPacketsLost;

/**
 Video packets send
 */
@property (nonatomic, readonly, nullable) NSString *videoSendPacketsSent;

/**
 Video send encode usage percent
 */
@property (nonatomic, readonly, nullable) NSString *videoSendEncodeUsagePercent;

/**
 Video send unique identifier
 */
@property (nonatomic, readonly, nullable) NSString *videoSendTrackID;

/**
 Average video encoding time
 */
@property (nonatomic, readonly, nullable) NSString *videoSendEncodeMs;

/**
 Video send input frame rate
 */
@property (nonatomic, readonly, nullable) NSString *videoSendInputFps;

/**
 Video send input height
 */
@property (nonatomic, readonly, nullable) NSString *videoSendInputHeight;

/**
 Video send input width
 */
@property (nonatomic, readonly, nullable) NSString *videoSendInputWidth;

/**
 Video send codec: VP8 or H264
 */
@property (nonatomic, readonly, nullable) NSString *videoSendCodec;

/**
 Video send bitrate
 */
@property (nonatomic, readonly, nullable) NSString *videoSendBitrate;

/**
 Video send frames per second (FPS)
 */
@property (nonatomic, readonly, nullable) NSString *videoSendFps;

/**
 Video send height
 */
@property (nonatomic, readonly, nullable) NSString *videoSendHeight;

/**
 Video send width
 */
@property (nonatomic, readonly, nullable) NSString *videoSendWidth;

/**
 Video send NACKs received
 */
@property (nonatomic, readonly, nullable) NSString *videoSendNacksReceived;

/**
 Video send plis received
 */
@property (nonatomic, readonly, nullable) NSString *videoSendPlisReceived;

/**
 Video send view limited resolution
 */
@property (nonatomic, readonly, nullable) NSString *videoSendViewLimitedResolution;

/**
 Video send cpu limited resolution
 */
@property (nonatomic, readonly, nullable) NSString *videoSendCpuLimitedResolution;

// MARK: Video receive stats

/**
 Packets lost on video received
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedPacketsLost;

/**
 Time spent decoding video in ms
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedDecodeMs;

/**
 Video received decoded frames per second (FPS)
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedDecodedFps;

/**
 Real frames per second output, after processing
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedOutputFps;

/**
 Video received frames per second (FPS)
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedFps;

/**
 Video received bitrate
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedBitrate;

/**
 Video received height
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedHeight;

/**
 Video received width
 */
@property (nonatomic, readonly, nullable) NSString *videoReceivedWidth;

// MARK: Audio send stats

/**
 Bitrate of the sent audio
 */
@property (nonatomic, readonly, nullable) NSString *audioSendBitrate;

/**
 Audio send input level
 
 You can use this property even if audio track is disabled
 to check if you are currently speaking/talking etc (for your sent audio).
 */
@property (nonatomic, readonly, nullable) NSString *audioSendInputLevel;

/**
 Bitrate of the sent audio, but without any changes or processing
 */
@property (nonatomic, readonly, nullable) NSString *audioSendBytesSent;

/**
 Number of lost packets of the sent audio
 */
@property (nonatomic, readonly, nullable) NSString *audioSendPacketsLost;

/**
 Number of packet sent of the sent audio
 */
@property (nonatomic, readonly, nullable) NSString *audioSendPacketsSent;

/**
 Name of the sent audio codec: OPUS, ISAC or iLBC
 */
@property (nonatomic, readonly, nullable) NSString *audioSendCodec;

/**
 Audio send track unique identifier
 */
@property (nonatomic, readonly, nullable) NSString *audioSendTrackID;

/**
 Receive-side jitter in milliseconds
 */
@property (nonatomic, readonly, nullable) NSString *audioSendJitterReceived;

// MARK: Audio receive stats

/**
 Audio received input level
 
 You can use this property even if audio track is disabled
 to check if user is currently speaking/talking etc.
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedOutputLevel;

/**
 Audio received current delay, in ms
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedCurrentDelay;

/**
 Number of lost packets of the received audio
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedPacketsLost;

/**
 Received audio packets number
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedPacketsReceived;

/**
 Unique identifier of the received audio track
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedTrackId;

/**
 The speech expand rate measures the amount of speech expansion done by NetEQ
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedExpandRate;

/**
 Audio received bitrate
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedBitrate;

/**
 Name of the received audio codec: OPUS, ISAC or iLBC
 */
@property (nonatomic, readonly, nullable) NSString *audioReceivedCodec;

// MARK: QP stats

/**
 Video QP Sum
 
 Only valid for video. QP (quantization parameter) describes how much
 spatial detail is included a frame. Low value corresponds with good
 quality. The range of the value per frame is defined by the codec
 being used. This parameter represents the sum of all QPs for
 framesDecoded on remote streams and framesSent on local streams.
 */
@property (nonatomic, readonly, nullable) NSString *videoQPSum;

/**
 Number of frames encoded.
 */
@property (nonatomic, readonly, nullable) NSString *framesEncoded;

/**
 Parsing all reasonable stats into readable string.
 
 @code
 (cpu)61%
 CN 565ms | local->local/udp | (s)248Kbps | (r)869Kbps
 VS (input) 640x480@30fps | (sent) 640x480@30fps
 VS (enc) 279Kbps/260Kbps | (sent) 200Kbps/292Kbps | 8ms | H264
 AvgQP (past 30 encoded frames) = 36
 VR (recv) 640x480@26fps | (decoded)27 | (output)27fps | 827Kbps/0bps | 4ms
 AS 38Kbps | opus
 AR 37Kbps | opus | 168ms | (expandrate)0.190002
 Packets lost: VS 17 | VR 0 | AS 3 | AR 0
 @endcode
 
 @return Readable stats
 */
- (NSString *)statsString;

@end

NS_ASSUME_NONNULL_END
