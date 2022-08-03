//
//  SearchUsersViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 30.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "UserListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchUsersViewController : UserListViewController
@property (strong, nonatomic) NSString *searchText;
@end

NS_ASSUME_NONNULL_END
