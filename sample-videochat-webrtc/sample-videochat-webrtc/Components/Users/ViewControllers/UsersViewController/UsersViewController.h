//
//  UsersViewController.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SignOutAction)(void);

@interface UsersViewController : UIViewController
@property (nonatomic, strong) SignOutAction onSignOut;
@end

NS_ASSUME_NONNULL_END
