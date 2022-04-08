//
//  BaseDialogsViewController.h
//  sample-chat
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
#import "ProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DialogListViewController : UITableViewController
@property (nonatomic, strong) NSArray<QBChatDialog *> *dialogs;
@property (nonatomic, strong) ChatManager *chatManager;
@property (nonatomic, strong) ProgressView *progressView;

- (void)reloadContent;
- (void)setupViews;
- (void)configureCell:(DialogCell *)cell
         forIndexPath:(NSIndexPath *)indexPath;
- (void)setupNavigationTitle;
- (void)handleLeaveDialog;
@end

NS_ASSUME_NONNULL_END
