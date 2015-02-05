//
//  QBRTCConnectionState.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 16.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

typedef NS_ENUM(NSUInteger, QBRTCConnectionState) {
    
    QBRTCConnectionUnknow,
    QBRTCConnectionNew,
    QBRTCConnectionWait,
    QBRTCConnectionConnecting,
    QBRTCConnectionDisconnected,
    QBRTCConnectionConnected,
    QBRTCConnectionClosed,
    QBRTCConnectionNotAnser,
    QBRTCConnectionReject,
    QBRTCConnectionFailed
};

typedef NS_ENUM (NSUInteger, QBConferenceType){
    
    QBConferenceTypeAudio,
    QBConferenceTypeVideo
};