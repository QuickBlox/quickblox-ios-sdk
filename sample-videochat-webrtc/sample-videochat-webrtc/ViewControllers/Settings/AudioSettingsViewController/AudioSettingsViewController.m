//
//  AudioSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
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
    AudioSettingsSectionAudioCodec = 1,
    AudioSettingsSectionBandwidth = 2
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
        case AudioSettingsSectionAudioCodec:
            return @"Codecs";
        case AudioSettingsSectionBandwidth:
            return @"Bandwidth";
    }
    
    return nil;
}

- (void)configure {
    
    __weak __typeof(self)weakSelf = self;
    
    //Constraints
    [self addSectionWith:AudioSettingsSectionConstraints items:^NSArray * _Nonnull(NSString * _Nonnull sectionTitle) {
        
        //audio level control
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Audio level control";
        switchItem.on = weakSelf.settings.mediaConfiguration.audioLevelControlEnabled;
        
        return @[switchItem];
    }];
    
    //Audio codecs
    [self addSectionWith:AudioSettingsSectionAudioCodec items:^NSArray *(NSString *sectionTitle) {
        
        BaseItemModel *opusModel = [[BaseItemModel alloc] init];
        opusModel.title = @"Opus";
        opusModel.data = @(QBRTCAudioCodecOpus);
        
        BaseItemModel *isacModel = [[BaseItemModel alloc] init];
        isacModel.title = @"ISAC";
        isacModel.data = @(QBRTCAudioCodecISAC);
        
        BaseItemModel *iLBCModel = [[BaseItemModel alloc] init];
        iLBCModel.title = @"iLBC";
        iLBCModel.data = @(QBRTCAudioCodeciLBC);
        
        [weakSelf selectSection:AudioSettingsSectionAudioCodec index:(NSUInteger)weakSelf.settings.mediaConfiguration.audioCodec];
        
        return @[opusModel, isacModel, iLBCModel];
    }];
    //Bandwidth
    [self addSectionWith:AudioSettingsSectionBandwidth items:^NSArray *(NSString *sectionTitle) {
        
        //Camera position section
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Enable";
        
        BOOL isEnabled = (weakSelf.settings.mediaConfiguration.audioBandwidth > 0);
        switchItem.on = isEnabled;
        
        SliderItemModel *bandwidthSlider = [[SliderItemModel alloc] init];
        bandwidthSlider.title = @"30";
        [weakSelf updateBandwidthSliderModelRange:bandwidthSlider usingCodec:weakSelf.settings.mediaConfiguration.audioCodec];
        bandwidthSlider.currentValue = weakSelf.settings.mediaConfiguration.audioBandwidth < bandwidthSlider.minValue ? bandwidthSlider.minValue : weakSelf.settings.mediaConfiguration.audioBandwidth;
        
        bandwidthSlider.disable = !isEnabled;
        
        return @[switchItem, bandwidthSlider];
    }];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case AudioSettingsSectionAudioCodec:
            [self updateSelectionAtIndexPath:indexPath];
            [self updateBandwidthValueForIndexPath:indexPath];
            break;
    }
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

- (void)updateBandwidthValueForIndexPath:(NSIndexPath *)indexPath {
    
    SettingsSectionModel *bandwidth = [self sectionWith:AudioSettingsSectionBandwidth];
    SwitchItemModel *switchItem = bandwidth.items[AudioBandwidthSectionEnable];
    SliderItemModel *bandwidthSlider = bandwidth.items[AudioBandwidthSectionBandwidth];
    BaseItemModel *audioCodec = [self modelWithIndex:indexPath.row section:indexPath.section];
    [self updateBandwidthSliderModelRange:bandwidthSlider usingCodec:(QBRTCAudioCodec)[(NSNumber *)audioCodec.data integerValue]];
    
    bandwidthSlider.disable = YES;
    switchItem.on = NO;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:AudioSettingsSectionBandwidth]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)applySettings {
    
    //APPLY SETTINGS
    
    //constraints
    SettingsSectionModel *constraints = [self sectionWith:AudioSettingsSectionConstraints];
    SwitchItemModel *levelControlSwitch = constraints.items.firstObject;
    self.settings.mediaConfiguration.audioLevelControlEnabled = levelControlSwitch.on;
    
    //Video codec
    NSIndexPath *audioCodecIndexPath = [self indexPathAtSection:AudioSettingsSectionAudioCodec];
    BaseItemModel *audioCodec = [self modelWithIndex:audioCodecIndexPath.row section:audioCodecIndexPath.section];
    self.settings.mediaConfiguration.audioCodec = (QBRTCAudioCodec)[(NSNumber *)audioCodec.data integerValue];
    
    //bandwidth
    SettingsSectionModel *bandwidth = [self sectionWith:AudioSettingsSectionBandwidth];
    SwitchItemModel *switchItem = bandwidth.items[AudioBandwidthSectionEnable];
    BOOL isEnabled = switchItem.on;
    if (isEnabled) {
        
        SliderItemModel *bandwidthSlider = bandwidth.items[AudioBandwidthSectionBandwidth];
        self.settings.mediaConfiguration.audioBandwidth = bandwidthSlider.currentValue;
    }
    else {
        self.settings.mediaConfiguration.audioBandwidth = 0;
    }
}

@end
