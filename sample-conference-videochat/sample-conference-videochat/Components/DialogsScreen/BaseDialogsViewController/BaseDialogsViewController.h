//
//  BaseDialogsViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 02.02.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>
#import "ChatManager.h"
#import "UIColor+Chat.h"
#import "Log.h"
#import "DialogCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^OnConnectAction)(void);

@interface BaseDialogsViewController : UITableViewController
@property (nonatomic, strong) NSArray<QBChatDialog *> *dialogs;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) OnConnectAction onConnect;

- (void)reloadContent;

@end

NS_ASSUME_NONNULL_END
