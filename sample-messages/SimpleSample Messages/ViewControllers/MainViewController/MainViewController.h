//
//  MainViewController.h
//  SimpleSample-messages_users-ios
//
//  Created by Igor Khomenko on 2/16/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Messages module (in particular,
// how to use Push Notifications through QuickBlox).
// It shows how to register to receive Push Notifications,
// how to send Push to a particular user and how to receive push notifications.
// Also it shows how Rich Push Notifications work.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIAlertViewDelegate, QBActionStatusDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
}
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSMutableArray *messages;

@property (nonatomic, retain) IBOutlet UITextField *messageBody;
@property (retain, nonatomic) IBOutlet UITableView *receivedMassages;
@property (nonatomic, retain) IBOutlet UILabel *toUserName;
@property (nonatomic, retain) IBOutlet UIPickerView *usersPickerView;

- (IBAction)sendButtonDidPress:(id)sender;
- (IBAction)selectUserButtonDidPress:(id)sender;
- (IBAction)buttonRichClicked:(UIButton*)sender;

- (void) showPickerWithUsers;

@end
