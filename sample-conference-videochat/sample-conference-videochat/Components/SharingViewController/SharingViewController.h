//
//  SharingViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SharingScreenCapture.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CloseSharingScreen)(void);
typedef void(^SetupSharingScreenCapture)(SharingScreenCapture *screenCapture);

@interface SharingViewController : BaseViewController
@property (strong, nonatomic) CloseSharingScreen didCloseSharingVC;
@property (strong, nonatomic) SetupSharingScreenCapture didSetupSharingScreenCapture;

@end

NS_ASSUME_NONNULL_END
