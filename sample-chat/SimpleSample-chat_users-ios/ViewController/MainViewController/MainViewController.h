//
//  MainViewController.h
//  SimpleSample-chat_users-ios
//
//  Created by Ruslan on 9/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class shows how to work with QuickBlox Chat module.
// It shows all users & allows to start chat 1-1 or create chat room
// Also it allows to join to any existing room
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, QBActionStatusDelegate, QBChatDelegate>{
    
    NSTimer *sendPresenceTimer; 
    NSTimer *requestRoomsTimer;
    NSTimer *requesAllUsersTimer;
}

@property (nonatomic, retain) NSTimer *requesAllUsersTimer;

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSMutableArray *selectedUsers;
@property (nonatomic, retain) NSMutableArray *senderUsers;

@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)login;
- (void)startChat;

@end
