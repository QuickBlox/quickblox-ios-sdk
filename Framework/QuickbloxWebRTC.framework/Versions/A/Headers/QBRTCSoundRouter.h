//
//  QBRTCSoundRouter.h
//  QuickbloxWebRTC
//
//  Created by Andrey Ivanov on 27.03.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBRTCSoundRoute) {
    
    QBRTCSoundRouteNotDefined,
    QBRTCSoundRouteSpeaker,
    QBRTCSoundRouteReceiver
};

/**
 * Class used to manage audio routes
 * To change output from speaker to receiver(headset) use currentSoundRoute property
 */
@interface QBRTCSoundRouter : NSObject

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/// @return QBRTCSoundRouter instance
+ (instancetype)instance;

/**
 *  Shows if we have saved current audio router settings with -initialize method
 *
 *  @return YES if we successfully called -initialize method before, NO otherwise
 */
- (BOOL)isActive;

/**
 *  Call this method when you want to start a call and you want to save current audio router settings
 * 
 * @return YES if success, NO if router failed to save current audio settings
 */
- (BOOL)initialize;

/**
 *  call this method when you want to restore previously saved audio router settings saved with "-initialize" method
 *
 *  @return YES if audio router settings is successfully restored to initial state, NO if router can not restore
 */
- (BOOL)deinitialize;

/// @return YES if headset or headphones are plugged in
@property (assign, nonatomic, readonly) BOOL isHeadsetPluggedIn;

/// @return QBRTCSoundRouteReceiver, QBRTCSoundRouteSpeaker, or QBRTCSoundRouteNotDefined if there is a problem
@property (assign, nonatomic) QBRTCSoundRoute currentSoundRoute;

@end
