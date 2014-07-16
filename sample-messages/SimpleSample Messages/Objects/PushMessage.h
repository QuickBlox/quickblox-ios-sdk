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

#import <Foundation/Foundation.h>

@interface PushMessage : NSObject {
}
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSArray *richContentFilesIDs;

+ (PushMessage *)pushMessageWithMessage:(NSString *)_message richContentFilesIDs:(NSString *)_richContentFilesIDs;

@end
