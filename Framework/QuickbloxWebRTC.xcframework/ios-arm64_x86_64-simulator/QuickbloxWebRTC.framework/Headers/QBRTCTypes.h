//
//  QBRTCTypes.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#ifndef __QBRTC__TYPES__
#define __QBRTC__TYPES__

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

/**
 *  Connection state.
 *
 *  - QBRTCConnectionUnknown: connection state is unknown; this can occur when non of the others states are fit for the current situation
 *  - QBRTCConnectionNew: connection was created and ready for the next step
 *  - QBRTCConnectionPending: connection is in pending state for other actions to occur
 *  - QBRTCConnectionConnecting: one or more of the ICE transports are currently in the process of establishing a connection
 *  - QBRTCConnectionChecking: the ICE agent has been given one or more remote candidates and is checking pairs of local and remote candidates against one another to try to find a compatible match, but has not yet found a pair which will allow the peer connection to be made; it's possible that gathering of candidates is also still underway
 *  - QBRTCConnectionConnected: connection was performed successfully
 *  - QBRTCConnectionDisconnected:  disconnected, but not closed; can still be reconnected
 *  - QBRTCConnectionClosed: connection was closed
 *  - QBRTCConnectionCount: ICE connection reached max numbers
 *  - QBRTCConnectionDisconnectTimeout: connection was disconnected by timeout
 *  - QBRTCConnectionNoAnswer: connection did not receive answer from the opponent user
 *  - QBRTCConnectionRejected: connection was rejected by the opponent user
 *  - QBRTCConnectionHangUp: connection was hanged up by the opponent user
 *  - QBRTCConnectionFailed: one or more of the ICE transports on the connection is in the failed state; this can occur on the different circumstances, e.g. bad network etc.
 */
typedef NS_ENUM(NSUInteger, QBRTCConnectionState) {
    
    QBRTCConnectionStateUnknown = 0,
    QBRTCConnectionStateNew,
    QBRTCConnectionStatePending,
    QBRTCConnectionStateConnecting,
    QBRTCConnectionStateChecking,
    QBRTCConnectionStateConnected,
    QBRTCConnectionStateDisconnected,
    QBRTCConnectionStateClosed,
    QBRTCConnectionStateCount,
    QBRTCConnectionStateDisconnectTimeout,
    QBRTCConnectionStateNoAnswer,
    QBRTCConnectionStateRejected,
    QBRTCConnectionStateHangUp,
    QBRTCConnectionStateFailed
};

/**
 *  Reconnection state.
 *
 *  - QBRTCReconnectionStateReconnecting: one or more of the ICE transports are currently in the process of establishing a connection
 *  - QBRTCReconnectionStateReconnected: connection was performed successfully
 *  - QBRTCReconnectionStateFailed: one or more of the ICE transports on the connection is in the failed state;
 */
typedef NS_ENUM(NSUInteger, QBRTCReconnectionState) {
  QBRTCReconnectionStateReconnecting,
  QBRTCReconnectionStateReconnected,
  QBRTCReconnectionStateFailed
};

/**
 *  Session state.
 *
 *  - QBRTCSessionStateNew: session was successfully created and ready for the next step
 *  - QBRTCSessionStatePending: session is in pending state for other actions to occur
 *  - QBRTCSessionStateConnecting: session is in progress of establishing connection
 *  - QBRTCSessionStateConnected: session was successfully established
 *  - QBRTCSessionStateClosed: session was closed
 */
typedef NS_ENUM(NSUInteger, QBRTCSessionState) {
    
    QBRTCSessionStateNew,
    QBRTCSessionStatePending,
    QBRTCSessionStateConnecting,
    QBRTCSessionStateConnected,
    QBRTCSessionStateClosed
};

/**
 *  Quickblox WebRTC conference types.
 *
 *  - QBRTCConferenceTypeVideo: video conference type
 *  - QBRTCConferenceTypeAudio: audio conference type
 */
typedef NS_ENUM (NSUInteger, QBRTCConferenceType) {
    
    QBRTCConferenceTypeVideo = 1,
    QBRTCConferenceTypeAudio = 2,
};

/**
 *  Available pixel formats.
 *
 *  - QBRTCPixelFormat420f: Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
 *  -  QBRTCPixelFormatARGB: 32 bit ARGB
 */
typedef NS_ENUM(OSType, QBRTCPixelFormat) {
    
    QBRTCPixelFormat420f = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
    QBRTCPixelFormatARGB = kCVPixelFormatType_32ARGB
};

/**
 *  Log level.
 *
 *  - QBRTCLogLevelNothing: Nothing in Log
 *  - QBRTCLogLevelErrors: Can see Errors
 *  - QBRTCLogLevelWarnings: Can see Warnings
 *  - QBRTCLogLevelInfo: Some Information Logs
 *  - QBRTCLogLevelVerbose: Full QuickbloxWebRTC Log
 *  - QBRTCLogLevelVerboseWithWebRTC: Full QuickbloxWebRTC and WebRTC native Log
 */
typedef NS_ENUM(NSInteger, QBRTCLogLevel) {
    
    QBRTCLogLevelNothing = 0,
    QBRTCLogLevelErrors,
    QBRTCLogLevelWarnings,
    QBRTCLogLevelInfo,
    QBRTCLogLevelVerbose,
    QBRTCLogLevelVerboseWithWebRTC
};

/**
 *  Video rotation.
 *
 *  - QBRTCVideoRotation_0: no rotation
 *  - QBRTCVideoRotation_90: 90 degrees rotation
 *  - QBRTCVideoRotation_180: 180 degrees rotation
 *  - QBRTCVideoRotation_270: 270 degrees rotation
 */
typedef NS_ENUM(NSUInteger, QBRTCVideoRotation) {
    
    QBRTCVideoRotation_0 = 0,
    QBRTCVideoRotation_90 = 90,
    QBRTCVideoRotation_180 = 180,
    QBRTCVideoRotation_270 = 270
};

/**
 *  Conference media type.
 *
 *  - QBRTCConferenceMediaTypeUnknown: Unknown / not supported media type
 *  - QBRTCConferenceMediaTypeAudio: media type audio
 *  - QBRTCConferenceMediaTypeVideo: media type video
 */
typedef NS_ENUM(NSUInteger, QBRTCConferenceMediaType) {
    QBRTCConferenceMediaTypeUnknown,
    QBRTCConferenceMediaTypeAudio,
    QBRTCConferenceMediaTypeVideo
};

#endif
