//
//  ConferenceInfo.h
//  sample-conference-videochat
//
//  Created by Injoit on 22.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceInfo : NSObject
@property (strong, nonatomic) NSString *callType;
@property (strong, nonatomic) NSString *chatDialogID;
@property (strong, nonatomic) NSString *conferenceID;
@property (strong, nonatomic) NSNumber *initiatorID;

- (instancetype)initWithCallType:(NSString *)callType chatDialogID:(NSString *)chatDialogID conferenceID:(NSString *)conferenceID initiatorID:(NSNumber *)initiatorID;

@end

NS_ASSUME_NONNULL_END
