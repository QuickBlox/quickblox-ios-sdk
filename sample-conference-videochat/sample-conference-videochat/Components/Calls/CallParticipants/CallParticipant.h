//
//  CallParticipant.h
//  sample-conference-videochat
//
//  Created by Injoit on 15.09.2020.
//  Copyright © 2020 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallParticipant : NSObject
@property (assign, nonatomic, readonly) NSNumber *ID;
@property (strong, nonatomic) NSString *fullName;
@property (assign, nonatomic) QBRTCConnectionState connectionState;
@property (assign, nonatomic) BOOL isCameraEnabled;
@property (assign, nonatomic) BOOL isEnabledSound;

- (instancetype)initWithID:(NSNumber *)ID fullName:(NSString *)fullName;

@end

NS_ASSUME_NONNULL_END
