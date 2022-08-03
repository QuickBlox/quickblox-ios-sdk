//
//  CallParticipant.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallParticipant : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *fullName;
@property (assign, nonatomic) QBRTCConnectionState connectionState;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) BOOL isEnabledSound;

- (instancetype)initWithParticipantId:(NSNumber *)participantId fullName:(NSString *)fullName;

@end

NS_ASSUME_NONNULL_END
