//
//  EnterChatNameVC.h
//  sample-conference-videochat
//
//  Created by Injoit on 04.02.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnterChatNameVC : UIViewController
@property (strong, nonatomic) NSArray<QBUUser *> *selectedUsers;
@end

NS_ASSUME_NONNULL_END
