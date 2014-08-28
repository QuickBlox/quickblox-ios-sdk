//
//  RichContentViewController.h
//  SimpleSample Messages
//
//  Created by Ruslan on 9/6/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class downloads rich push content and shows it
//

@class SSMPushMessage;
@interface SSMRichContentViewController : UIViewController

@property (strong, nonatomic) SSMPushMessage *message;

@end
