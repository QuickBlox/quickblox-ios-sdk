//
//  DialogsViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "BaseDialogsViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OpenChatScreen)(QBChatDialog *dialog, BOOL isNewCreated);
typedef void(^SignInAction)(void);

@interface DialogsViewController : BaseDialogsViewController
@property (nonatomic, strong) OpenChatScreen openChatScreen;
@property (nonatomic, strong) SignInAction onSignIn;
@end

NS_ASSUME_NONNULL_END
