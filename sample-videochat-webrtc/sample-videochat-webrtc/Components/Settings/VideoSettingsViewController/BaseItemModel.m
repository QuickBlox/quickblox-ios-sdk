//
//  BaseItemModel.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "BaseItemModel.h"
#import "SettingCell.h"

@implementation BaseItemModel

- (Class)viewClass {
    
    return [SettingCell class];
}

@end
