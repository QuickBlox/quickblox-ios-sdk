//
//  QBChatAbstractMessage.h
//  Quickblox
//
//  Created by Igor Alefirenko on 12/05/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatAbstractMessage : NSObject <NSCoding, NSCopying>

/**
 Unique identifier of message (sequential number)
 */
@property (nonatomic, copy) NSString *ID;

/**
 Message text
 */
@property (nonatomic, copy) NSString *text;

/**
 Message receiver ID
 */
@property (nonatomic, assign) NSUInteger recipientID;

/**
 Message sender ID, use only for 1-1 Chat
 */
@property (nonatomic, assign) NSUInteger senderID;

/**
 Message datetime
 */
@property (nonatomic, retain) NSDate *datetime;

/**
 Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, retain) NSMutableDictionary *customParameters;

/**
 Array of attachments. Array of QBChatAttachment instances.
 */
@property (nonatomic, retain) NSArray *attachments;

@end
