//
//  QBChatMessageCreateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/31/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBChatQuery.h"

@class QBChatHistoryMessage;
@interface QBChatMessageCreateQuery : QBChatQuery

@property (nonatomic, retain) QBChatHistoryMessage *message;

- (id)initWithMessage:(QBChatHistoryMessage *)message;

@end
