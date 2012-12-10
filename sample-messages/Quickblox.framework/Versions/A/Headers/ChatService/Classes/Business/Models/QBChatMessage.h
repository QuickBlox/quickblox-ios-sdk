//
//  QBChatMessage.h
//  Сhat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text and recipientID values since ID and senderID
 are setted automatically by QBChat
 */

@interface QBChatMessage : NSObject <NSCoding, NSCopying>{
@private
    NSUInteger ID;
    NSString *text;
    NSUInteger recipientID;
    NSUInteger senderID;
    NSDate *datetime;
    BOOL delayed;
}

/**
 Unique identifier of message (sequential number)
 */
@property (nonatomic, assign) NSUInteger ID;

/**
 Message text
 */
@property (nonatomic, retain) NSString *text;

/**
 Message receiver ID
 */
@property (nonatomic, assign) NSUInteger recipientID;

/**
 Message sender ID
 */
@property (nonatomic, assign) NSUInteger senderID;

/**
 Message datetime
 */
@property (nonatomic, retain) NSDate *datetime;

/**
 Is this message delayed
 */
@property (nonatomic, assign) BOOL delayed;


@end
