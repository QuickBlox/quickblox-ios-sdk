//
//  QMChatSection.h
//  QMChatViewController
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//  Copyright (c) 2016 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatMessage;

@interface QMChatSection : NSObject

/** Messages in section */
@property (strong, nonatomic) NSMutableArray *messages;

/** Date of first message in section */
@property (strong, nonatomic, readonly) NSDate *firstMessageDate;

/** Date of last message in section */
@property (strong, nonatomic, readonly) NSDate *lastMessageDate;

/** Constructor */
- (instancetype)initWithMessage:(QBChatMessage *)message;

/**
 *  New QMChatSection instance.
 *
 *  @return new QMChatSection instance
 */
+ (QMChatSection *)chatSection;

/**
 *  New QMChatSection instance with message.
 *
 *  @param message  message to add
 *
 *  @return new QMChatSection instance with message
 */
+ (QMChatSection *)chatSectionWithMessage:(QBChatMessage *)message;

/**
 *  Insert message to chat section using sorting method by date sent.
 *
 *  @param message message to insert
 *
 *  @return index of inserted message
 */
- (NSUInteger)insertMessage:(QBChatMessage *)message;

/**
 *  Index that conforms to message using sorting method by date sent.
 *
 *  @param message message to calculate index with
 *
 *  @return index that conforms to message using sorting method by datesent
 */
- (NSUInteger)indexThatConformsToMessage:(QBChatMessage *)message;

/**
 *  Determines whether chat section is empty
 *
 *  @return boolean value of chat section being empty
 */
- (BOOL)isEmpty;

@end
