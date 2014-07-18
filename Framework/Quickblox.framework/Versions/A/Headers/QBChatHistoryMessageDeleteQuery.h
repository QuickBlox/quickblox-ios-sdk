//
//  QBChatHistoryMessageDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 6/17/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBChatQuery.h"

@interface QBChatHistoryMessageDeleteQuery : QBChatQuery

@property (nonatomic, readonly, retain) NSString *messageID;

- (instancetype)initWithMessageID:(NSString *)messageID;

@end