//
//  CallViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRTCSession;
@class UsersDataSource;

@interface CallViewController : UIViewController

@property (strong, nonatomic) QBRTCSession *session;
@property (weak, nonatomic) UsersDataSource *usersDatasource;
@property (strong, nonatomic) NSUUID *callUUID;

@end
