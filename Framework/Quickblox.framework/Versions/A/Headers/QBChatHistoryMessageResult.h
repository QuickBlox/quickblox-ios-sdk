//
//  QBChatHistoryMessageResult.h
//  Quickblox
//
//  Created by Igor Alefirenko on 30/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "Result.h"

@interface QBChatHistoryMessageResult : Result

@property (nonatomic, readonly) NSMutableArray *messages;

@end
