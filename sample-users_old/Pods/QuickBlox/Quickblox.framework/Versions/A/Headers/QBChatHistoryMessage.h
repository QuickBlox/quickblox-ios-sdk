//
//  QBChatHistoryMessage.h
//  Quickblox
//
//  Created by Igor Alefirenko on 23/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBChatAbstractMessage.h"

@interface QBChatHistoryMessage : QBChatAbstractMessage <NSCoding, NSCopying>

/**
 Unique identifier of chat dialog
 */
@property (nonatomic, copy) NSString *dialogID;

/**
 Message flag. Mark this flag
 */
@property (nonatomic, getter = isRead) BOOL read;

@end
