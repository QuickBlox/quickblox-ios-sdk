//
//  QBModuleProtocol.h
//  QuickbloxWebRTC
//
//  Created by Andrey on 01.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//
@class QBXMPPMessage;
@class QBXMPPStream;

@protocol QBModuleProtocol <NSObject>

@optional

- (void)chatDidLogin;
- (void)chatDidLogout;
- (void)chatDidNotLogin;

@required

- (NSString *)moduleIdentifier;
- (void)handleMessage:(QBXMPPMessage *)message;

@end
