//
//  ActionsMenuView.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 15.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActionsMenuView : UIView

- (void)addAction:(MenuAction *)action;

@end

NS_ASSUME_NONNULL_END
