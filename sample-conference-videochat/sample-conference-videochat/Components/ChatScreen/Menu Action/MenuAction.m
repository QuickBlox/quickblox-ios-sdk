//
//  MenuAction.m
//  sample-conference-videochat
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "MenuAction.h"

@implementation MenuAction

- (instancetype)initWithTitle:(NSString *)title action:(ChatAction)action handler:(MenuActionHandler _Nullable)handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.action = action;
        self.handler = handler;
    }
    return self;
}

@end
