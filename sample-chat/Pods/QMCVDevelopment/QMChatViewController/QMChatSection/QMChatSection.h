//
//  QMChatSection.h
//  Pods
//
//  Created by Vitaliy Gorbachov on 11/16/15.
//
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

@end
