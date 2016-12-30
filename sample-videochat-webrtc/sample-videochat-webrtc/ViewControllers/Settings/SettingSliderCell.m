//
//  SettingSliderCell.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 30/09/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "SettingSliderCell.h"
#import "SliderItemModel.h"

@interface SettingSliderCell()

@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation SettingSliderCell

@synthesize model = _model;

- (void)setModel:(SliderItemModel *)model {
    
    _model = model;
    
    self.label.text = [NSString stringWithFormat:@"%tu", model.currentValue];
    self.maxLabel.text = [NSString stringWithFormat:@"%tu", model.maxValue];
    self.minLabel.text = [NSString stringWithFormat:@"%tu", model.minValue];
    self.slider.minimumValue = model.minValue;
    self.slider.maximumValue = model.maxValue;
    self.slider.value = model.currentValue;
    
    BOOL isEnabled = !model.isDisabled;
    self.slider.enabled = isEnabled;
    self.maxLabel.enabled = isEnabled;
    self.minLabel.enabled = isEnabled;
}

- (IBAction)valueChanged:(UISlider *)sender {
    
    SliderItemModel *model = (SliderItemModel *)self.model;
    model.currentValue = sender.value;
    self.label.text = [NSString stringWithFormat:@"%tu", model.currentValue];
}

@end
