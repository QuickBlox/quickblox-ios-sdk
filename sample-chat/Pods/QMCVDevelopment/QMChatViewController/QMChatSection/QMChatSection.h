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

/** Section name */
@property (strong, nonatomic, readonly) NSString *name;

/** Messages in section */
@property (strong, nonatomic) NSMutableArray *messages;

/** Date of first message in section */
@property (strong, nonatomic, readonly) NSDate *firstMessageDate;

/** Date of last message in section */
@property (strong, nonatomic, readonly) NSDate *lastMessageDate;

/**
 *  New QMChatSection instance.
 *
 *  @return new QMChatSection instance
 */
+ (QMChatSection *)chatSection;

@end
