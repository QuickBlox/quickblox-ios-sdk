//
//  LoginTagViewController.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/11/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTagViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIButton *login;
@property (nonatomic, weak) IBOutlet UITextField *userName;
@property (nonatomic, weak) IBOutlet UITextField *tag;

@end
