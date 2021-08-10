//
//  ConferenceSettings.h
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConferenceInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceSettings : NSObject
@property (strong, nonatomic) ConferenceInfo *conferenceInfo;
@property (assign, nonatomic) BOOL isSendMessage;

- (instancetype)initWithConferenceInfo:(ConferenceInfo *)conferenceInfo isSendMessage:(BOOL)isSendMessage;
@end

NS_ASSUME_NONNULL_END
