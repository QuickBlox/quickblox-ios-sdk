//
//  QBModuleProtocol.h
//  QuickbloxWebRTC
//
//  Created by Andrey on 01.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

@protocol QBModuleProtocol <NSObject>

@required

- (NSString *)moduleIdentifier;
- (void)handleMessage:(id)message;

@end
