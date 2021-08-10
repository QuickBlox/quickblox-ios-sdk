//
//  ConferenceInfo.m
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "ConferenceInfo.h"

@implementation ConferenceInfo
- (instancetype)initWithCallType:(NSString *)callType chatDialogID:(NSString *)chatDialogID conferenceID:(NSString *)conferenceID initiatorID:(NSNumber *)initiatorID {
    self = [super init];
    if (self) {
        self.callType = callType;
        self.chatDialogID = chatDialogID;
        self.conferenceID = conferenceID;
        self.initiatorID = initiatorID;
    }
    return self;
}
@end
