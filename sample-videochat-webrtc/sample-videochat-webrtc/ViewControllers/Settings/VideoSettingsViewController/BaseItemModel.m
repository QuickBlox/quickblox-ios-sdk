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

- (Class)viewClass {
    
    return [SettingCell class];
}

@end
