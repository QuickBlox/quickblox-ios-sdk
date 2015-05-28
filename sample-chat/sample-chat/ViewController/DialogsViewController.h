//
//  SecondViewController.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogsViewController : UITableViewController

@property (strong, nonatomic) QBChatDialog *createdDialog;

@end
