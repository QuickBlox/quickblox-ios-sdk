//
//  ConferenceUser.h
//  sample-conference-videochat
//
//  Created by Injoit on 6/1/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConferenceUser : NSObject
@property (assign, nonatomic, readonly) NSNumber *ID;
@property (strong, nonatomic, readonly) NSString *fullName;
@property (assign, nonatomic) QBRTCConnectionState connectionState;

- (instancetype)initWithID:(NSUInteger)ID fullName:(NSString *)fullName;

@end

NS_ASSUME_NONNULL_END
