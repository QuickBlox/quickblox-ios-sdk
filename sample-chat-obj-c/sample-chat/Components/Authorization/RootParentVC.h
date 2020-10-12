//
//  RootParentVC.h
//  samplechat
//
//  Created by Injoit on 1/29/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootParentVC : UIViewController
@property (nonatomic, strong) NSString * _Nullable dialogID;
- (void)showLoginScreen;
- (void)showDialogsScreen;
@end

NS_ASSUME_NONNULL_END
