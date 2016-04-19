//
//  SliderItemModel.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SliderItemModel.h"
#import "SettingSliderCell.h"

@implementation SliderItemModel

- (Class)viewClass {
    
    return [SettingSliderCell class];
}

@end
