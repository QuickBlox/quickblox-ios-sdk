//
//  UsersInfoTableViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "BaseUsersViewController.h"
#import "ChatDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface UsersInfoTableViewController : BaseUsersViewController
@property (strong, nonatomic) NSString *dialogID;
@property (nonatomic, assign) ChatAction action;
@property (nonatomic, strong) QBChatMessage *message;
@property (strong, nonatomic) ChatDataSource *dataSource;
@end

NS_ASSUME_NONNULL_END
