//
//  QBChatDialogUpdateQuery.h
//  Quickblox
//
//  Created by Igor Alefirenko on 11/06/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//


#import "QBChatQuery.h"

@interface QBChatDialogUpdateQuery : QBChatQuery

@property (nonatomic, readonly, retain) NSString *chatDialogID;
@property (nonatomic, readonly, retain) NSMutableDictionary *extendedRequest;

- (instancetype)initWithChatDialogID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest;

@end