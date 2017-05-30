//
//  RecordSettingsViewController.m
//  sample-videochat-webrtc-old
//
//  Created by Vitaliy Gorbachov on 4/18/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

#import "RecordSettingsViewController.h"
#import "Settings.h"
#import "RecordSettings.h"

#import "SettingCell.h"
#import "SettingSliderCell.h"
#import "SettingSwitchCell.h"

#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"

typedef NS_ENUM(NSUInteger, RecordSettingsSectionType) {
    
    RecordSettingsSectionEnable = 0,
    RecordSettingsSectionRotation = 1,
    RecordSettingsSectionVideoFormat = 2,
    RecordSettingsSectionFrameRate = 3
};

@interface RecordSettingsViewController ()

@end

@implementation RecordSettingsViewController

- (NSString *)titleForSection:(NSUInteger)section {
    
    switch (section) {
        case RecordSettingsSectionEnable:
            return @"Record";
        case RecordSettingsSectionRotation:
            return @"Video frame orientation";
        case RecordSettingsSectionVideoFormat:
            return @"Video format";
        case RecordSettingsSectionFrameRate:
            return @"Frame rate";
    }
    
    return nil;
}

- (NSArray *)videoFormatModelsWithCameraPositon:(AVCaptureDevicePosition)cameraPosition {
    //Grab supported formats
    
    NSArray *formats = [QBRTCCameraCapture formatsWithPosition:cameraPosition];
    
    NSMutableArray *videoFormatModels = [NSMutableArray arrayWithCapacity:formats.count];
    for (QBRTCVideoFormat *videoFormat in formats) {
        
        BaseItemModel *videoFormatModel = [[BaseItemModel alloc] init];
        videoFormatModel.title = [NSString stringWithFormat:@"%tux%tu", videoFormat.width, videoFormat.height];
        videoFormatModel.data = videoFormat;
        [videoFormatModels addObject:videoFormatModel];
    }
    
    return videoFormatModels;
}

- (void)configure {
    
    //Record enable section
    __weak __typeof(self)weakSelf = self;
    [self addSectionWith:RecordSettingsSectionEnable items:^NSArray *(NSString *sectionTitle) {
        
        //Camera position section
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Enable";
        
        switchItem.on = weakSelf.settings.recordSettings.isEnabled;
        
        return @[switchItem];
    }];
    //Video codecs
    [self addSectionWith:RecordSettingsSectionRotation items:^NSArray *(NSString *sectionTitle) {
        
        BaseItemModel *zeroDegreeModel = [[BaseItemModel alloc] init];
        zeroDegreeModel.title = @"0°";
        zeroDegreeModel.data = @(QBRTCVideoRotation_0);
        
        BaseItemModel *ninetyDegreeModel = [[BaseItemModel alloc] init];
        ninetyDegreeModel.title = @"90°";
        ninetyDegreeModel.data = @(QBRTCVideoRotation_90);
        
        BaseItemModel *hundredEightyDegreeModel = [[BaseItemModel alloc] init];
        hundredEightyDegreeModel.title = @"180°";
        hundredEightyDegreeModel.data = @(QBRTCVideoRotation_180);
        
        BaseItemModel *twoHundredSeventyDegreeModel = [[BaseItemModel alloc] init];
        twoHundredSeventyDegreeModel.title = @"270°";
        twoHundredSeventyDegreeModel.data = @(QBRTCVideoRotation_270);
        
        [weakSelf selectSection:RecordSettingsSectionRotation index:[weakSelf indexForVideoRotation:weakSelf.settings.recordSettings.videoRotation]];
        
        return @[zeroDegreeModel, ninetyDegreeModel, hundredEightyDegreeModel, twoHundredSeventyDegreeModel];
    }];
    //Supported video formats section
    [self addSectionWith:RecordSettingsSectionVideoFormat items:^NSArray *(NSString *sectionTitle) {
        
        NSArray *videoFormats = [weakSelf videoFormatModelsWithCameraPositon:AVCaptureDevicePositionFront];
        NSArray *formats = [QBRTCCameraCapture formatsWithPosition:AVCaptureDevicePositionFront];
        //Select index path
        QBRTCVideoFormat *videoFormat = [QBRTCVideoFormat defaultFormat];
        videoFormat.width = weakSelf.settings.recordSettings.width;
        videoFormat.height = weakSelf.settings.recordSettings.height;
        NSUInteger idx = [formats indexOfObject:videoFormat];
        [weakSelf selectSection:RecordSettingsSectionVideoFormat index:idx];
        
        return videoFormats;
    }];
    //Frame rate
    [self addSectionWith:RecordSettingsSectionFrameRate items:^NSArray *(NSString *sectionTitle) {
        
        SliderItemModel *frameRateSlider = [[SliderItemModel alloc] init];
        frameRateSlider.title = @"30";
        frameRateSlider.minValue = 2;
        frameRateSlider.currentValue = weakSelf.settings.recordSettings.fps;
        frameRateSlider.maxValue = 30;
        
        return @[frameRateSlider];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case RecordSettingsSectionRotation:
        case RecordSettingsSectionVideoFormat:
            [self updateSelectionAtIndexPath:indexPath];
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == RecordSettingsSectionEnable) {
        return NSLocalizedString(@"Currently only 1 to 1 audio and video calls supported", @"Recorder explanation");
    }
    return [super tableView:tableView titleForFooterInSection:section];
}

#pragma mark - SettingsCellDelegate

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model {
    
    if ([model isKindOfClass:[SwitchItemModel class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)applySettings {
    
    //APPLY SETTINGS
    
    //Preferred camera positon
    SwitchItemModel *recordEnabled = (id)[self modelWithIndex:0 section:RecordSettingsSectionEnable];
    self.settings.recordSettings.enabled = recordEnabled.on;
    
    //Video codec
    NSIndexPath *rotationIndexPath = [self indexPathAtSection:RecordSettingsSectionRotation];
    BaseItemModel *videoRotation = [self modelWithIndex:rotationIndexPath.row section:rotationIndexPath.section];
    self.settings.recordSettings.videoRotation = (QBRTCVideoRotation)[(NSNumber *)videoRotation.data integerValue];
    
    //Record video format
    NSIndexPath *supportedFormatIndexPath = [self indexPathAtSection:RecordSettingsSectionVideoFormat];
    BaseItemModel *format = [self modelWithIndex:supportedFormatIndexPath.row section:supportedFormatIndexPath.section];
    QBRTCVideoFormat *videoFormat = format.data;
    self.settings.recordSettings.width = videoFormat.width;
    self.settings.recordSettings.height = videoFormat.height;
    
    //Frame rate
    SettingsSectionModel *frameRate = [self sectionWith:RecordSettingsSectionFrameRate];
    SliderItemModel *frameRateSlider = frameRate.items.firstObject;
    self.settings.recordSettings.fps = frameRateSlider.currentValue;
}

- (NSUInteger)indexForVideoRotation:(QBRTCVideoRotation)videoRotation {
    NSUInteger index = 0;
    switch (videoRotation) {
        case QBRTCVideoRotation_0:
            index = 0;
            break;
        case QBRTCVideoRotation_90:
            index = 1;
            break;
        case QBRTCVideoRotation_180:
            index = 2;
            break;
        case QBRTCVideoRotation_270:
            index = 3;
            break;
    }
    return index;
}

@end
