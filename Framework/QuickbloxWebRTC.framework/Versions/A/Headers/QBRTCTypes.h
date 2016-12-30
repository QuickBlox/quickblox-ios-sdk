//
//  QBRTCConnectionState.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#ifndef __QBRTC__TYPES__
#define __QBRTC__TYPES__

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

/**
 *  Connection state.
 *
 *  - QBRTCConnectionUnknown: connection state is unknown
 *  - QBRTCConnectionNew: connection state created
 *  - QBRTCConnectionPending: connection is in pending state
 *  - QBRTCConnectionConnecting: connection in progress
 *  - QBRTCConnectionChecking: checking connected
 *  - QBRTCConnectionConnected: connected
 *  - QBRTCConnectionDisconnected: disconnected
 *  - QBRTCConnectionClosed: connection was closed
 *  - QBRTCConnectionCount: count state3
 *  - QBRTCConnectionDisconnectTimeout: disconnected by timeout
 *  - QBRTCConnectionNoAnswer: no answer
 *  - QBRTCConnectionRejected: connection was rejected
 *  - QBRTCConnectionHangUp: connection hang up
 *  - QBRTCConnectionFailed: connection failed
 */
typedef NS_ENUM(NSUInteger, QBRTCConnectionState) {
    
    QBRTCConnectionStateUnknown,
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
 *  Session state.
 *
 *  - QBRTCSessionStateNew: created session
 *  - QBRTCSessionStatePending: session is in pending state
 *  - QBRTCSessionStateConnecting: connection in progress
 *  - QBRTCSessionStateConnected: session is connected
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

typedef NS_ENUM(OSType, QBRTCPixelFormat) {
    
    /**
     *   Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
     */
    QBRTCPixelFormat420f = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
    
    /**
     *  Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).  baseAddr points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
     *
     *  @warning *Deprecated in 2.3.* Not implemented by SDK.
     */
    QBRTCPixelFormat420v __deprecated_enum_msg("Deprecated in 2.3. Not implemented by SDK.") = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    
    /**
     *  32 bit BGRA
     *
     *  @warning *Deprecated in 2.3.* Not implemented by SDK.
     */
    QBRTCPixelFormatBGRA __deprecated_enum_msg("Deprecated in 2.3. Not implemented by SDK.") = kCVPixelFormatType_32BGRA,
    
    /**
     *  32 bit ARGB
     */
    QBRTCPixelFormatARGB = kCVPixelFormatType_32ARGB,
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

#endif
