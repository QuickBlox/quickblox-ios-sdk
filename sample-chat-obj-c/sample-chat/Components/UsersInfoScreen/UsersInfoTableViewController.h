//
//  UsersInfoTableViewController.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import <Quickblox/Quickblox.h>
#import "ChatDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface UsersInfoTableViewController : UITableViewController
@property (strong, nonatomic) NSString *dialogID;
@property (nonatomic, assign) ChatActions action;
@property (nonatomic, strong) QBChatMessage *message;
@property (strong, nonatomic) ChatDataSource *dataSource;
@end

NS_ASSUME_NONNULL_END
