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
	/// Internal receiver, Headset and Heaphones are classified as receiver
    QBRTCSoundRouteReceiver
};

/**
 * QuickBlox WebRTC sound router
 * Allows to manage audio routes with currentSoundRoute property
 */
@interface QBRTCSoundRouter : NSObject

- (instancetype)init __attribute__((unavailable("init is not a supported initializer for this class.")));

/// @return QBRTCSoundRouter instance
+ (instancetype)instance;

/**
 *  Shows whether the router is initialized or not
 *
 *  @return YES if the router is active
 */
- (BOOL)isActive;

/**
 *  Initializes sound router
 *
 * @return YES if success, NO if router has already been initialized
 */
- (BOOL)initialize;

/**
 *  Call this method when you want to deinitialize sound router
 *
 *  @return YES if success, NO if router was not initialized
 */
- (BOOL)deinitialize;

/// @return YES if headset or headphones are plugged in
@property (assign, nonatomic, readonly) BOOL isHeadsetPluggedIn;

/// @return YES if bluetooth device is plugged in
@property (assign, nonatomic, readonly) BOOL isBluetoothPluggedIn;

/**
 *  Sets current sound route
 *
 *  @param currentSoundRoute QBRTCSoundRouteSpeaker and QBRTCSoundRouteReceiver are allowed values
 *
 *  @return YES if success, NO if error or currentSoundRoute already set
 */
- (BOOL)setCurrentSoundRoute:(QBRTCSoundRoute)currentSoundRoute;

/**
 *  KVO - observable
 *  @return QBRTCSoundRouteReceiver, QBRTCSoundRouteSpeaker, or QBRTCSoundRouteNotDefined if there is a problem
 */
@property(nonatomic, assign, readonly) QBRTCSoundRoute currentSoundRoute;

@end
