//
//  ConferenceSettings.m
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "ConferenceSettings.h"

@implementation ConferenceSettings
- (instancetype)initWithConferenceInfo:(ConferenceInfo *)conferenceInfo isSendMessage:(BOOL)isSendMessage {
    self = [super init];
    if (self) {
        self.conferenceInfo = conferenceInfo;
        self.isSendMessage = isSendMessage;
    }
    return self;
}
@end
