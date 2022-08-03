//
//  MenuAction.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 08.10.2020.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "MenuAction.h"

@interface MenuAction ()
//MARK: - Properties
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) UserAction action;
@property (assign, nonatomic) BOOL isSelected;
@property (strong, nonatomic) MenuActionHandler handler;

@end

@implementation MenuAction
//MARK: - Life Cycle
- (instancetype)initWithTitle:(NSString *)title isSelected:(BOOL)isSelected action:(UserAction)action handler:(MenuActionHandler _Nullable)handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.action = action;
        self.isSelected = isSelected;
        self.handler = handler;
    }
    return self;
}

@end
