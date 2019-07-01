//
//  SwitchItemModel.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "SwitchItemModel.h"
#import "SettingSwitchCell.h"

@implementation SwitchItemModel

- (Class)viewClass {
    
    return [SettingSwitchCell class];
}

@end
