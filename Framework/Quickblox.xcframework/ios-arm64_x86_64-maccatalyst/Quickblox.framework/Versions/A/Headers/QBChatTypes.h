//
//  QBChatTypes.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^QBPingCompleitonBlock)(NSTimeInterval timeInterval, BOOL success);
typedef void(^QBChatCompletionBlock)(NSError * _Nullable error);
typedef void(^QBChatDialogUserBlock)(NSUInteger userID);
typedef void(^QBUserLastActivityCompletionBlock)(NSUInteger seconds, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
