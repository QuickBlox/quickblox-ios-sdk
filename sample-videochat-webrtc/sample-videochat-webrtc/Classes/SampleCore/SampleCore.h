//
//  SampleCore.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/15/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UsersDataSourceProtocol;
@class PushMessagesManager;
@class Settings;
@class QMSoundManager;

/**
 *  Class to store services
 */
@interface SampleCore : NSObject

+ (void)setUsersDataSource:(id<UsersDataSourceProtocol>)dataSource;
+ (id<UsersDataSourceProtocol>)usersDataSource;

+ (void)setPushMessagesManager:(PushMessagesManager *)pushMessagesManager;
+ (PushMessagesManager *)pushMessagesManager;

+ (void)setSettings:(Settings *)settings;
+ (Settings *)settings;

+ (void)setSoundManager:(QMSoundManager *)soundManager;
+ (QMSoundManager *)soundManager;



@end
