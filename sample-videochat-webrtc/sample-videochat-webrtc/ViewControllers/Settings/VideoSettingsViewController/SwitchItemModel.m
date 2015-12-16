//
//  SwitchItemModel.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SwitchItemModel.h"
#import "SettingSwichCell.h"

@implementation SwitchItemModel

- (Class)viewClass {
    
    return [SettingSwichCell class];
}

@end
