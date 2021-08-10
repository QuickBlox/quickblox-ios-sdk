//
//  CallSettings.h
//  sample-conference-videochat
//
//  Created by Injoit on 13.06.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallSettings : NSObject
@property (strong, nonatomic) NSString *callType;
@property (strong, nonatomic) NSString *chatDialogID;
@property (strong, nonatomic) NSString *conferenceID;
@property (assign, nonatomic) NSUInteger initiatorID;
@property (assign, nonatomic) BOOL isSendMessage;

- (instancetype)initWithCallType:(NSString *)callType chatDialogID:(NSString *)chatDialogID conferenceID:(NSString *)conferenceID initiatorID:(NSUInteger)initiatorID isSendMessage:(BOOL)isSendMessage;
@end

NS_ASSUME_NONNULL_END
