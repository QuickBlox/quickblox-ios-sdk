//
//  DialogsSelectionVC.h
//  sample-chat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "ChatViewController.h"
#import "DialogListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialogsSelectionViewController : DialogListViewController
@property (nonatomic, assign) ChatAction action;
@property (nonatomic, strong) QBChatMessage *message;
@end

NS_ASSUME_NONNULL_END
