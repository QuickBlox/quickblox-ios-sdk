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

- (instancetype)initWithTitle:(NSString *)title minValue:(NSUInteger)minValue maxValue:(NSUInteger)maxValue currentValue:(NSUInteger)currentValue {
    self = [super initWithTitle:title];
    if (self) {
        self.title = title;
        self.minValue = minValue;
        self.maxValue = maxValue;
        self.currentValue = currentValue;
    }
    return self;
}

- (instancetype)initWithMinValue:(NSUInteger)minValue maxValue:(NSUInteger)maxValue currentValue:(NSUInteger)currentValue {
    return [self initWithTitle:@"" minValue:minValue maxValue:maxValue currentValue:currentValue];
}

- (Class)viewClass {
    
    return [SettingSliderCell class];
}

@end
