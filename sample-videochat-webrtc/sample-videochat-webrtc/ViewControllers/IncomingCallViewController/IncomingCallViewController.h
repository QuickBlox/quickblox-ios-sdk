//
//  IncomingCallViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UsersDataSource;
@protocol IncomingCallViewControllerDelegate;

@interface IncomingCallViewController : UIViewController

@property (weak, nonatomic) id <IncomingCallViewControllerDelegate> delegate;

@property (strong, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) UsersDataSource *usersDatasource;

@end

@protocol IncomingCallViewControllerDelegate <NSObject>

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session;
- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session;

@end
