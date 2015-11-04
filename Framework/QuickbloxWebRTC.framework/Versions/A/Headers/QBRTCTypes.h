//
//  QBRTCConnectionState.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 16.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

typedef NS_ENUM(NSUInteger, QBRTCConnectionState) {
    
    QBRTCConnectionUnknown,             //1
    QBRTCConnectionNew,                 //2
    QBRTCConnectionPending,             //3
    QBRTCConnectionConnecting,          //4
    QBRTCConnectionChecking,            //5
    QBRTCConnectionConnected,           //6
    QBRTCConnectionDisconnected,        //7
    
    QBRTCConnectionClosed,              //8
    QBRTCConnectionMax,                 //9
    QBRTCConnectionDisconnectTimeout,   //10
    QBRTCConnectionNoAnswer,            //11
    QBRTCConnectionRejected,            //12
    QBRTCConnectionHangUp,              //13
    QBRTCConnectionFailed               //14
};

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
     */
    QBRTCPixelFormat420v = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
    
    /**
     *  32 bit BGRA 
     */
    QBRTCPixelFormatBGRA = kCVPixelFormatType_32BGRA,
    /**
     *  32 bit ARGB
     */
    QBRTCPixelFormatARGB = kCVPixelFormatType_32ARGB,
};

