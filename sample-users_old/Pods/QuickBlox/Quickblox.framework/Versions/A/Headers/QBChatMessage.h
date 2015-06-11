//
//  QBChatMessage.h
//  Сhat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBChatAbstractMessage.h"

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text, recipientID & senderID values since ID is setted automatically by QBChat
 */

@interface QBChatMessage : QBChatAbstractMessage <NSCoding, NSCopying>{
}

/**
 Message sender nick, use only for group Chat 
 */
@property (nonatomic, copy) NSString *senderNick;

/**
 Is this message delayed
 */
@property (nonatomic, assign) BOOL delayed;

/**
 Custom Objects class name
 */
@property (nonatomic, copy) NSString *customObjectsClassName;

/**
 Additional Custom Objects fields
 */
@property (nonatomic, copy) NSDictionary *customObjectsAdditionalParameters;

/**
 Mark message as markable
 */
@property (nonatomic, assign) BOOL markable;

/** Create new message
 @return New instance of QBChatMessage
 */
+ (instancetype)message;

/** Create new markabe message
 @return New instance of QBChatMessage
 */
+ (instancetype)markableMessage;

/** Save message to history in Custom Objects
 
 @param classname Custom Objects class name
 @param additionalParameters Additional Custom Objects fields
 */
- (void)saveWhenDeliveredToCustomObjectsWithClassName:(NSString *)classname additionalParameters:(NSDictionary *)additionalParameters;

@end
