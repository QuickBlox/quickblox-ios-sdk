//
//  AudioSettingsViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "AudioSettingsViewController.h"
#import "Settings.h"

#import "SettingCell.h"
#import "SettingSliderCell.h"
#import "SettingSwitchCell.h"

#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"

typedef NS_ENUM(NSUInteger, AudioSettingsSectionType) {
    
    AudioSettingsSectionConstraints = 0,
    AudioSettingsSectionBandwidth = 1
};

typedef NS_ENUM(NSUInteger, AudioBandwidthSection) {
    
    AudioBandwidthSectionEnable = 0,
    AudioBandwidthSectionBandwidth
};

struct AudioCodecBandWidthRange {
    NSUInteger minValue;
    NSUInteger maxValue;
} AudioCodecBandWidthRange;

static inline struct AudioCodecBandWidthRange audioCodecRangeForCodec(QBRTCAudioCodec codec) {
    
    struct AudioCodecBandWidthRange range;
    switch (codec) {
        case QBRTCAudioCodecOpus:
            range.minValue = 6;
            range.maxValue = 510;
            break;
        case QBRTCAudioCodecISAC:
            range.minValue = 10;
            range.maxValue = 32;
            break;
        case QBRTCAudioCodeciLBC:
            range.minValue = 15;
            range.maxValue = 32;
            break;
    }
    
    return range;
}

@implementation AudioSettingsViewController

- (NSString *)titleForSection:(NSUInteger)section {
    
    switch (section) {
        case AudioSettingsSectionConstraints:
            return @"Constraints";
        case AudioSettingsSectionBandwidth:
            return @"Bandwidth";
    }
    
    return nil;
}

- (void)didTapBack:(UIButton *)sender {
    [self applySettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configure {
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    Settings *settings = [[Settings alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    
    //Constraints
    [self addSectionWith:AudioSettingsSectionConstraints items:^NSArray * _Nonnull(NSString * _Nonnull sectionTitle) {
        
        //audio level control
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Audio level control";
        switchItem.on = settings.mediaConfiguration.audioLevelControlEnabled;
        
        return @[switchItem];
    }];
    
    //Bandwidth
    [self addSectionWith:AudioSettingsSectionBandwidth items:^NSArray *(NSString *sectionTitle) {
        
        //Camera position section
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Enable";
        
        BOOL isEnabled = (settings.mediaConfiguration.audioBandwidth > 0);
        switchItem.on = isEnabled;
        
        SliderItemModel *bandwidthSlider = [[SliderItemModel alloc] init];
        bandwidthSlider.title = @"30";
        [weakSelf updateBandwidthSliderModelRange:bandwidthSlider usingCodec:settings.mediaConfiguration.audioCodec];
        bandwidthSlider.currentValue = settings.mediaConfiguration.audioBandwidth > bandwidthSlider.minValue ? settings.mediaConfiguration.audioBandwidth : bandwidthSlider.minValue;
        
        bandwidthSlider.disable = !isEnabled;
        
        return @[switchItem, bandwidthSlider];
    }];
}

#pragma mark - SettingsCellDelegate

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == AudioSettingsSectionBandwidth
        && [model isKindOfClass:[SwitchItemModel class]]) {
        
        SettingsSectionModel *bandwidth = [self sectionWith:AudioSettingsSectionBandwidth];
        SwitchItemModel *switchItem = bandwidth.items[AudioBandwidthSectionEnable];
        BOOL isEnabled = switchItem.on;
        SliderItemModel *bandwidthSlider = bandwidth.items[AudioBandwidthSectionBandwidth];
        bandwidthSlider.disable = !isEnabled;
        if (!isEnabled) {
            bandwidthSlider.currentValue = bandwidthSlider.minValue;
        }
        
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndex:AudioSettingsSectionBandwidth];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Helpers

- (void)updateBandwidthSliderModelRange:(SliderItemModel *)sliderModel
                             usingCodec:(QBRTCAudioCodec)codec {
    
    struct AudioCodecBandWidthRange range = audioCodecRangeForCodec(codec);
    sliderModel.currentValue = range.minValue;
    sliderModel.minValue = range.minValue;
    sliderModel.maxValue = range.maxValue;
}

- (void)applySettings {
    
    //APPLY SETTINGS
    Settings *settings = [[Settings alloc] init];
    //constraints
    SettingsSectionModel *constraints = [self sectionWith:AudioSettingsSectionConstraints];
    SwitchItemModel *levelControlSwitch = constraints.items.firstObject;
    settings.mediaConfiguration.audioLevelControlEnabled = levelControlSwitch.on;
    
    //bandwidth
    SettingsSectionModel *bandwidth = [self sectionWith:AudioSettingsSectionBandwidth];
    SwitchItemModel *switchItem = bandwidth.items[AudioBandwidthSectionEnable];
    BOOL isEnabled = switchItem.on;
    if (isEnabled) {
        
        SliderItemModel *bandwidthSlider = bandwidth.items[AudioBandwidthSectionBandwidth];
        settings.mediaConfiguration.audioBandwidth = bandwidthSlider.currentValue;
    }
    else {
        settings.mediaConfiguration.audioBandwidth = 0;
    }
    
    [settings applyConfig];
    [settings saveToDisk];
}

@end
