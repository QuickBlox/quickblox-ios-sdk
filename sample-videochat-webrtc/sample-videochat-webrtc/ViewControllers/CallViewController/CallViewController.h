//
//  CallViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCSession;
@class UsersDataSource;
@class AVPlayerViewController;

@interface CallViewController : UIViewController

@property (strong, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) UsersDataSource *usersDatasource;
@property (strong, nonatomic) NSUUID *callUUID;

@property (strong, nonatomic) AVPlayerViewController *playerVC;
@end
