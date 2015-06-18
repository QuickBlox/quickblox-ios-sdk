//
//  CallViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "BaseViewController.h"

@class QBRTCSession;

@interface CallViewController : BaseViewController

@property (strong, nonatomic) QBRTCSession *session;

@end
