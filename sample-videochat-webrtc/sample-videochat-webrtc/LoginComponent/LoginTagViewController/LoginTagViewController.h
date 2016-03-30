//
//  LoginTagViewController.h
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 1/11/16.
//  Copyright © 2016 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewControllerInput.h"
#import "LoginViewControllerOutput.h"

@interface LoginTagViewController : UITableViewController <LoginViewControllerInput>


@property (nonatomic, strong) id<LoginViewControllerOutput> output;

@property (nonatomic, weak) IBOutlet UIButton *login;
@property (nonatomic, weak) IBOutlet UITextField *userName;
@property (nonatomic, weak) IBOutlet UITextField *tag;

@end
