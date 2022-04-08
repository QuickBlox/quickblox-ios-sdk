//
//  ViewedByViewController.h
//  sample-chat
//
//  Created by Injoit on 07.03.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "UserListViewController.h"
#import "ChatDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewedByViewController : UserListViewController
@property (strong, nonatomic) NSString *dialogID;
@property (nonatomic, strong) NSString *messageID;
@property (strong, nonatomic) ChatDataSource *dataSource;
@end

NS_ASSUME_NONNULL_END
