//
//  QBWebRTCVideoTrack.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 13.01.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBRTCVideoTrack : NSObject

@property (assign, nonatomic, readonly) BOOL isRemote;

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
