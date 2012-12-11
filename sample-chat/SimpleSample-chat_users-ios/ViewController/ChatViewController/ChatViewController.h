//
//  ChatViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Chat module.
// It shows how works chat 1-1 or chat in room
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITextFieldDelegate, QBChatDelegate>{
}

@property (nonatomic, retain) QBUUser        *opponent;
@property (nonatomic, retain) QBChatRoom     *currentRoom;
@property (nonatomic, retain) NSMutableArray *messages;

@property (retain, nonatomic) IBOutlet UIToolbar   *toolBar;
@property (retain, nonatomic) IBOutlet UITextField *sendMessageField;
@property (retain, nonatomic) IBOutlet UIButton    *sendMessageButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)sendMessage:(id)sender;

@end
