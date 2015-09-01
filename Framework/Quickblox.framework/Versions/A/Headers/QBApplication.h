//
// Created by Andrey Kozlov on 15/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

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
+ (QBApplication *)sharedApplication;

/**
* Storing and accessing Application ID
*/
@property (nonatomic) NSUInteger applicationId;

/**
* Storing and accessing Rest API Version
*/
@property (nonatomic, copy) NSString *restAPIVersion;

/**
* Production or development environment for push notifications, works only if autoDetectEnvironment = NO.

 @warning Deprecated in 2.4. See 'autoDetectEnvironment'.
*/
@property (nonatomic, assign) BOOL productionEnvironmentForPushesEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.4. Please use automatic environment detection which is enabled by default.");

/**
 *  Automatically detects environment for push notifications. By default is - YES.
 */
@property (nonatomic, assign) BOOL autoDetectEnvironment;


@end