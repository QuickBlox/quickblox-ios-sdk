//
//  LoginViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class enables log in for QB users.
// Login window is only called when user wants to do some action with the map,
// for example mark his position for other users.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<QBActionStatusDelegate, QBChatDelegate, UITextFieldDelegate, UIAlertViewDelegate>{
    
}
@property (retain, nonatomic) IBOutlet UITextField *loginField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginWithFB:(id)sender;
- (IBAction)loginWithTitter:(id)sender;
- (IBAction)login:(id)sender;

@end
