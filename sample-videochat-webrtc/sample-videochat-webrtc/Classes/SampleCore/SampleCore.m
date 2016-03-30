//
//  SampleCore.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/15/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import "SampleCore.h"

@implementation SampleCore

static id _usersDataSource;
static id _settings;
static id _pushMessagesManager;
static id _chatManager;
static id _soundManager;

+ (void)setUsersDataSource:(id<UsersDataSourceProtocol>)dataSource {
	_usersDataSource = dataSource;
}

+ (id<UsersDataSourceProtocol>)usersDataSource {
	return _usersDataSource;
}

+ (void)setSettings:(Settings *)settings {
	_settings = settings;
}

+ (Settings *)settings {
	return _settings;
}

+ (void)setPushMessagesManager:(PushMessagesManager *)pushMessagesManager {
	_pushMessagesManager = pushMessagesManager;
}

+ (PushMessagesManager *)pushMessagesManager {
	return _pushMessagesManager;
}

+ (void)setChatManager:(ChatManager *)chatManager {
	_chatManager = chatManager;
}

+ (ChatManager *)chatManager {
	return _chatManager;
}

+ (void)setSoundManager:(QMSoundManager *)soundManager {
	_soundManager = soundManager;
}

+ (QMSoundManager *)soundManager {
	return _soundManager;
}



@end
