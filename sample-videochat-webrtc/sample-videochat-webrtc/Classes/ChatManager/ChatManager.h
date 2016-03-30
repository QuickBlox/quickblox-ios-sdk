//
//  ChatManager.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatManager : NSObject

// Indicate whether we have an active call or not
// If we in background, then do disconnect from chat
@property (nonatomic) BOOL hasActiveCall;

// Check hasActiveCall
- (void)disconnectIfNeededInBackground;

@end