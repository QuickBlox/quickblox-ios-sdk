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

@end
