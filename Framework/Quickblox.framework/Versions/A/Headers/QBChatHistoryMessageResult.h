//
//  QBChatHistoryMessageResult.h
//  Quickblox
//
//  Created by Igor Alefirenko on 30/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBResult.h"
/** QBChatHistoryMessageResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to the user after he made ​​the request for get chat messages. */

@interface QBChatHistoryMessageResult : QBResult

/** An array of QBChatHistoryMessage objects */
@property (nonatomic, readonly) NSMutableArray *messages;

@end
