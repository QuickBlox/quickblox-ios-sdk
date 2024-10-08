//
//  DialogsViewController.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogListViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SignOutAction)(void);

@interface DialogsViewController : DialogListViewController
@property (nonatomic, strong) SignOutAction onSignOut;
@end

NS_ASSUME_NONNULL_END
