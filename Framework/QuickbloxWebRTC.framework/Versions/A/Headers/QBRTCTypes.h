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
    QBRTCConnectionPending,
    QBRTCConnectionConnecting,
    QBRTCConnectionChecking,
    QBRTCConnectionConnected,
    QBRTCConnectionDisconnected,
    
    QBRTCConnectionClosed,
    QBRTCConnectionDisconnectTimeout,
    QBRTCConnectionNoAnswer,
    QBRTCConnectionRejected,
    QBRTCConnectionHangUp,
    QBRTCConnectionFailed
};

typedef NS_ENUM (NSUInteger, QBConferenceType){
    QBConferenceTypeVideo = 1,
    QBConferenceTypeAudio = 2
};

typedef NS_ENUM(NSUInteger, QBSoundRoute) {
    QBSoundRouteNotDefined,
    QBSoundRouteSpeaker,
    QBSoundRouteReceiver
};