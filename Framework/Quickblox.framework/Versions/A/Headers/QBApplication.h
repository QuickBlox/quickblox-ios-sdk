//
// Created by Andrey Kozlov on 15/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

/**
* Class representing Application.
* Should be used for Application related information storage and managing as ApplicationId, application Keys and other information.
*/
@interface QBApplication : NSObject

/**
* Shared instance of the QBApplication
*
* @return Instance of QBApplication
*/
+ (QB_NONNULL QBApplication *)sharedApplication;

/**
 *  Storing and accessing Application ID
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings applicationID], [QBSettings setApplicationID:] instead.
 */
@property (nonatomic) NSUInteger applicationId DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings applicationID], [QBSettings setApplicationID:] instead");

/**
 *  Storing and accessing Rest API Version
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings restAPIVersion] instead.
 */
@property (nonatomic, readonly, QB_NONNULL_PROPERTY) NSString *restAPIVersion DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings restAPIVersion] instead");

/**
* Production or development environment for push notifications, works only if autoDetectEnvironment = NO.

 @warning Deprecated in 2.4.4. See 'autoDetectEnvironment'.
*/
@property (nonatomic, assign) BOOL productionEnvironmentForPushesEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.4.4. Please use automatic environment detection which is enabled by default.");

/**
 *  Automatically detects environment for push notifications. By default is - YES.
 *
 *  @warning Deprecated in 2.4.4. Will be always enable.
 */
@property (nonatomic, assign) BOOL autoDetectEnvironment DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.4.4. Will be always enabled.");


@end