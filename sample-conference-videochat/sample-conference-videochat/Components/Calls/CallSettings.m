//
//  CallSettings.m
//  sample-conference-videochat
//
//  Created by Injoit on 13.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "CallSettings.h"

@implementation CallSettings

- (instancetype)initWithCallType:(NSString *)callType chatDialogID:(NSString *)chatDialogID conferenceID:(NSString *)conferenceID initiatorID:(NSUInteger)initiatorID isSendMessage:(BOOL)isSendMessage {
    self = [super init];
    if (self) {
        self.callType = callType;
        self.chatDialogID = chatDialogID;
        self.conferenceID = conferenceID;
        self.initiatorID = initiatorID;
        self.isSendMessage = isSendMessage;
    }
    return self;
}

@end
