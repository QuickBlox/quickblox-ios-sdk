//
//  ChatPopVC.h
//  samplechat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "MenuAction.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CancelAction)(void);

@interface ActionsMenuViewController : UITableViewController
@property (nonatomic, strong) CancelAction cancelAction;

- (void)addAction:(MenuAction *)action;

@end

NS_ASSUME_NONNULL_END
