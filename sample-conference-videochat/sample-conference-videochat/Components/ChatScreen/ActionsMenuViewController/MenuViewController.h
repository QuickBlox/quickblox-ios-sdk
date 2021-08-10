//
//  MenuViewController.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "MenuAction.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TypeMenu) {
    TypeMenuChatInfo = 0,
    TypeMenuMediaInfo,
    TypeMenuAppMenu
};


typedef void(^CancelAction)(void);

@interface MenuViewController : UIViewController
@property (nonatomic, strong) CancelAction cancelAction;
@property (nonatomic, assign) TypeMenu menuType;

- (void)addAction:(MenuAction *)action;

@end

NS_ASSUME_NONNULL_END
