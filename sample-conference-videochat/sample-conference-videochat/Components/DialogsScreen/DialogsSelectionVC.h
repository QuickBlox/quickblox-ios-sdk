//
//  DialogsSelectionVC.h
//  sample-conference-videochat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ChatViewController.h"
#import "BaseDialogsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialogsSelectionVC : BaseDialogsViewController
@property (nonatomic, assign) ChatAction action;
@property (nonatomic, strong) QBChatMessage *message;
@end

NS_ASSUME_NONNULL_END
