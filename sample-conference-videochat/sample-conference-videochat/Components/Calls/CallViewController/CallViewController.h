//
//  CallViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBChatDialog;
@class UsersDataSource;

@interface CallViewController : UIViewController

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (assign, nonatomic) QBRTCConferenceType conferenceType;
@property (weak, nonatomic) UsersDataSource *usersDataSource;

@end
