//
//  DialogsSelectionVC.h
//  samplechat
//
//  Created by Injoit on 1/31/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface DialogsSelectionVC : UITableViewController
@property (nonatomic, assign) ChatActions action;
@property (nonatomic, strong) QBChatMessage *message;
@end

NS_ASSUME_NONNULL_END
