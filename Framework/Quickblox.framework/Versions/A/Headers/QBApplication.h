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
* Production or development environment for push notifications
*/
@property (nonatomic, assign) BOOL productionEnvironmentForPushesEnabled;

@end