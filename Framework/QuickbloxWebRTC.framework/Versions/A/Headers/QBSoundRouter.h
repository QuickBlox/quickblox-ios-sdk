//
//  QBSoundRouter.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 27.03.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRTCTypes.h"

@interface QBSoundRouter : NSObject

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

+ (instancetype)instance;

- (BOOL)isActive;

- (BOOL)initialize;
- (BOOL)deinitialize;

@property (assign, nonatomic, readonly) BOOL isHeadsetPluggedIn;

@property (assign, nonatomic) QBSoundRoute currentSoundRoute;

@end
