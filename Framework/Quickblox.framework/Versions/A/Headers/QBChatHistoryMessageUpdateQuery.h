//
//  QBChatHistoryMessageUpdateQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/17/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBChatQuery.h"

@class QBChatHistoryMessage;
@interface QBChatHistoryMessageUpdateQuery : QBChatQuery

@property (nonatomic, readonly, retain) QBChatHistoryMessage *message;

- (instancetype)initWithMessage:(QBChatHistoryMessage *)message;

@end