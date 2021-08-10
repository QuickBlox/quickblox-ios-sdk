//
//  MenuAction.h
//  sample-conference-videochat
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MenuActionHandler)(ChatAction action);

@interface MenuAction : NSObject

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) ChatAction action;
@property (strong, nonatomic) MenuActionHandler handler;

- (instancetype)initWithTitle:(NSString *)title action:(ChatAction)action handler:(MenuActionHandler _Nullable)handler;

@end

NS_ASSUME_NONNULL_END
