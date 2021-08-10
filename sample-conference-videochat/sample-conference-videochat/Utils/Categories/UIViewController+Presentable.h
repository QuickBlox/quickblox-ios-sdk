//
//  UIViewController+Presentable.h
//  sample-conference-videochat
//
//  Created by Injoit on 25.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PresentableProtocol <NSObject>
@required
- (UIViewController *)toPresent;
@end

@protocol BaseView <PresentableProtocol>
@end

@interface UIViewController (Presentable)
- (UIViewController *)toPresent;
@end

NS_ASSUME_NONNULL_END
