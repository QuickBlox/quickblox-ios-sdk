//
//  QBChatMessageResult.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/31/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

/** QBChatMessageResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to the user after he made ​​the request for create a message. */
#import "QBResult.h"

@class QBChatHistoryMessage;
@interface QBChatMessageResult : QBResult

/** An instance of QBChatHistoryMessage */
@property (nonatomic, readonly) QBChatHistoryMessage *message;

@end
