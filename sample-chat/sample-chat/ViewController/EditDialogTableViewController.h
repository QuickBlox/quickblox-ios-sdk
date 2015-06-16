//
//  EditDialogTableViewController.h
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginTableViewController.h"

@interface EditDialogTableViewController : UITableViewController

@property (nonatomic, strong) QBChatDialog *dialog;

@end
