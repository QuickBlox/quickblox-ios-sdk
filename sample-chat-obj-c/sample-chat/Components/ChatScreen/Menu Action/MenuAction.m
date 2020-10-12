//
//  MenuAction.m
//  samplechat
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "MenuAction.h"

@implementation MenuAction

- (instancetype)initWithTitle:(NSString *)title handler:(MenuActionHandler _Nullable)handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.handler = handler;
    }
    return self;
}

@end
