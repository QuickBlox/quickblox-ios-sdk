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

/**
 *  Call this method when you want to start a call and you want to save current audio router settings
 * 
 * @return YES if success, NO if failed to save current audio settings
 */
- (BOOL)initialize;

/**
 *  call this method when you want to restore previously saved audio router settings saved with "initialize" method
 *
 *  @return YES if audio router settings is successfully restored, NO if can not restore
 */
- (BOOL)deinitialize;

@property (assign, nonatomic, readonly) BOOL isHeadsetPluggedIn;

@property (assign, nonatomic) QBSoundRoute currentSoundRoute;

@end
