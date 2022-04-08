//
//  SplashScreenVC.h
//  sample-chat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompleteAuth)(BOOL isSuccess);

@interface SplashScreenViewController : UIViewController
@property (nonatomic, strong) CompleteAuth onCompleteAuth;
@end

NS_ASSUME_NONNULL_END
