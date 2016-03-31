//
//  BaseItemModel.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "BaseItemModel.h"
#import "SettingCell.h"

@implementation BaseItemModel

- (instancetype)initWithTitle:(NSString *)title data:(id)data {
    self = [super init];
    if (self) {
        self.title = title;
        self.data = data;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithTitle:title data:nil];
}


- (Class)viewClass {
    
    return [SettingCell class];
}

@end
