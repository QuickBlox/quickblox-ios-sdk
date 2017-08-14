//
//  Enums.h
//  Quickblox
//
//  Created by QuickBlox team on 1/11/13.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QBPingCompleitonBlock)(NSTimeInterval timeInterval, BOOL success);
typedef void(^QBChatCompletionBlock)(NSError * _Nullable error);
typedef void(^QBChatDialogRequestOnlineUsersCompletionBlock)(NSMutableArray <NSNumber *> * _Nullable onlineUsers, NSError * _Nullable error);
typedef void(^QBChatDialogUserBlock)(NSUInteger userID);
typedef void(^QBUserLastActivityCompletionBlock)(NSUInteger seconds, NSError * _Nullable error);
