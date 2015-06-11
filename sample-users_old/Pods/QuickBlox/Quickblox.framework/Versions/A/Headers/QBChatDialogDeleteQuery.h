//
//  QBChatDialogDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/20/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBChatQuery.h"

@interface QBChatDialogDeleteQuery : QBChatQuery

@property (nonatomic, readonly, retain) NSString *dialogID;

- (instancetype)initWithDialogID:(NSString *)dialogID;

@end
