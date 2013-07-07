//
//  QBChatMessage.h
//  Сhat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text, recipientID & senderID values since ID is setted automatically by QBChat
 */

@interface QBChatMessage : NSObject <NSCoding, NSCopying>{
@private
    NSString *ID;
    NSString *text;
    
    NSUInteger recipientID;
    NSUInteger senderID;
    
    NSDate *datetime;
    BOOL delayed;
    
    NSMutableDictionary *customParameters;
}

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
@property (nonatomic, copy) NSDate *datetime;

/**
 Is this message delayed
 */
@property (nonatomic, assign) BOOL delayed;

/**
 Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, retain) NSMutableDictionary *customParameters;

/** Create new message
 @return New instance of QBChatMessage
 */
+ (instancetype)message;

@end
