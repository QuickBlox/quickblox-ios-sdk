//
//  InfoUsersController.h
//  sample-chat
//
//  Created by Injoit on 22.02.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface InfoUsersController : UserListViewController
@property (strong, nonatomic) NSString *dialogID;
@end

NS_ASSUME_NONNULL_END
