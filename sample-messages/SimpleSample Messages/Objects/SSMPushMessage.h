//
//  PushMessage.h
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents push message body
//

@interface SSMPushMessage : NSObject

@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSArray *richContentFilesIDs;

+ (instancetype)pushMessageWithMessage:(NSString *)message richContentFilesIDs:(NSString *)richContentFilesIDs;

@end
