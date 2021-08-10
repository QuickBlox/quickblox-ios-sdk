//
//  LoadingButton.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingButton : UIButton

@property(assign, nonatomic) BOOL isAnimating;

- (void)showLoading;
- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
