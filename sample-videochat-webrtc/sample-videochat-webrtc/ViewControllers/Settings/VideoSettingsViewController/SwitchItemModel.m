//
//  SwitchItemModel.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SwitchItemModel.h"
#import "SettingSwitchCell.h"

@implementation SwitchItemModel

- (instancetype)initWithTitle:(NSString *)title data:(id)data on:(BOOL)on changedBlock:(void (^)(BOOL isOn))changedBlock {
    self = [super initWithTitle:title data:data];
    if (self){
        self.on = on;
        self.changedBlock = changedBlock;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title data:(id)data on:(BOOL)on {
    return [self initWithTitle:title data:data on:on changedBlock:nil];
}

- (Class)viewClass {
    
    return [SettingSwitchCell class];
}

@end
