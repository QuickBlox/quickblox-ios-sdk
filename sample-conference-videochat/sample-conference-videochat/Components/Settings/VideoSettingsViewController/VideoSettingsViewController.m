//
//  SettingsViewController.m
//  sample-conference-videochat
//
//  Created by Injoit on 21.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "VideoSettingsViewController.h"
#import "Settings.h"

#import "SettingCell.h"
#import "SettingSliderCell.h"
#import "SettingSwitchCell.h"

#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"

typedef NS_ENUM(NSUInteger, VideoSettingsSectionType) {
    
    VideoSettingsSectionCameraPostion = 0,
    VideoSettingsSectionSupportedFormats = 1,
    VideoSettingsSectionVideoFrameRate = 2,
    VideoSettingsSectionBandwidth = 3
};

@implementation VideoSettingsViewController

- (NSString *)titleForSection:(NSUInteger)section {
    
    switch (section) {
        case VideoSettingsSectionCameraPostion:
            return @"Switch camera position";
        case VideoSettingsSectionSupportedFormats:
            return @"Video formats";
        case VideoSettingsSectionVideoFrameRate:
            return @"Frame rate";
        case VideoSettingsSectionBandwidth:
            return @"Bandwidth";
    }
    
    return nil;
}

- (NSArray *)videoFormatModelsWithCameraPositon:(AVCaptureDevicePosition)cameraPosition {
    //Grab supported formats
    
    NSArray *formats = [QBRTCCameraCapture formatsWithPosition:cameraPosition];
    NSPredicate *formatsPredicate = [NSPredicate predicateWithFormat:@"width <= %i", 1024];
    formats = [formats filteredArrayUsingPredicate:formatsPredicate];
    
    NSMutableArray *videoFormatModels = [NSMutableArray arrayWithCapacity:formats.count];
    for (QBRTCVideoFormat *videoFormat in formats) {
        
        BaseItemModel *videoFormatModel = [[BaseItemModel alloc] init];
        videoFormatModel.title = [NSString stringWithFormat:@"%tux%tu", videoFormat.width, videoFormat.height];
        videoFormatModel.data = videoFormat;
        [videoFormatModels addObject:videoFormatModel];
    }
    
    return videoFormatModels;
}

- (void)didTapBack:(UIButton *)sender {
    [self applySettings];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configure {
    Settings *settings = [[Settings alloc] init];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chevron"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didTapBack:)];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    backButtonItem.tintColor = UIColor.whiteColor;
    
    //Camera position section
    __weak __typeof(self)weakSelf = self;
    [self addSectionWith:VideoSettingsSectionCameraPostion items:^NSArray *(NSString *sectionTitle) {
        
        //Camera position section
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Back Camera";
        
        switchItem.on = (settings.preferredCameraPostion == AVCaptureDevicePositionBack);
        
        return @[switchItem];
    }];
    //Supported video formats section
    [self addSectionWith:VideoSettingsSectionSupportedFormats items:^NSArray *(NSString *sectionTitle) {
        
        AVCaptureDevicePosition position = settings.preferredCameraPostion;
        NSArray *videoFormats = [weakSelf videoFormatModelsWithCameraPositon:position];
        
        NSArray *formats = [QBRTCCameraCapture formatsWithPosition:position];
        NSPredicate *formatsPredicate = [NSPredicate predicateWithFormat:@"width <= %i", 1024];
        formats = [formats filteredArrayUsingPredicate:formatsPredicate];

        //Select index path
        NSUInteger idx = [formats indexOfObject:settings.videoFormat];
        [weakSelf selectSection:VideoSettingsSectionSupportedFormats index:idx];
        
        return videoFormats;
    }];
    //Frame rate
    [self addSectionWith:VideoSettingsSectionVideoFrameRate items:^NSArray *(NSString *sectionTitle) {
        
        SliderItemModel *frameRateSlider = [[SliderItemModel alloc] init];
        frameRateSlider.title = @"30";
        frameRateSlider.minValue = 2;
        frameRateSlider.currentValue = settings.videoFormat.frameRate;
        frameRateSlider.maxValue = 30;
        
        return @[frameRateSlider];
    }];
    //Video bandwidth
    [self addSectionWith:VideoSettingsSectionBandwidth items:^NSArray *(NSString *sectionTitle) {
        
        SliderItemModel *bandwidthSlider = [[SliderItemModel alloc] init];
        bandwidthSlider.title = @"30";
        bandwidthSlider.minValue = 0;
        bandwidthSlider.currentValue = settings.mediaConfiguration.videoBandwidth;
        bandwidthSlider.maxValue = 2000;
        
        return @[bandwidthSlider];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
            
        case VideoSettingsSectionSupportedFormats: {
            
            [self updateSelectionAtIndexPath:indexPath];
            break;
        }
        default:
            break;
    }
}

#pragma mark - SettingsCellDelegate

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model {
#if !(TARGET_IPHONE_SIMULATOR)
    if ([model isKindOfClass:[SwitchItemModel class]]) {
        [self reloadVideoFormatSectionForPosition:((SwitchItemModel *)model).on ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront];
    }
#endif
}

#pragma mark - Helpers

- (void)reloadVideoFormatSectionForPosition:(AVCaptureDevicePosition)position {
    
    NSArray *videoFormatModels = [self videoFormatModelsWithCameraPositon:position];
    
    SettingsSectionModel *section = [self sectionWith:VideoSettingsSectionSupportedFormats];
    section.items = videoFormatModels;
    
    NSArray<QBRTCVideoFormat *> *formats = [QBRTCCameraCapture formatsWithPosition:position];
    
    
    NSString *title = [self titleForSection:VideoSettingsSectionSupportedFormats];
    NSIndexPath *oldIdnexPath = self.selectedIndexes[title];
    //Select index path
    
    NSUInteger idx = section.items.count - 1;
    if (idx >= oldIdnexPath.row) {
        
        BaseItemModel *videoFormatModel = section.items[oldIdnexPath.row];
        QBRTCVideoFormat *videoFormat = videoFormatModel.data;
        
        idx = [formats indexOfObject:videoFormat];
    }
    
    [self selectSection:VideoSettingsSectionSupportedFormats index:idx];
    
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndex:VideoSettingsSectionSupportedFormats];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
}

- (void)applySettings {
    
    //APPLY SETTINGS
    Settings *settings = [[Settings alloc] init];
    //Preferred camera positon
    SwitchItemModel *cameraPostion = (id)[self modelWithIndex:0 section:VideoSettingsSectionCameraPostion];
    settings.preferredCameraPostion = cameraPostion.on ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    //Frame rate
    SettingsSectionModel *frameRate = [self sectionWith:VideoSettingsSectionVideoFrameRate];
    SliderItemModel *frameRateSlider = frameRate.items.firstObject;
    
    //bandwidth
    SettingsSectionModel *bandwidth = [self sectionWith:VideoSettingsSectionBandwidth];
    SliderItemModel *bandwidthSlider = bandwidth.items.firstObject;
    
    settings.mediaConfiguration.videoBandwidth = bandwidthSlider.currentValue;
    
    //Supported format
#if !(TARGET_IPHONE_SIMULATOR)
    NSIndexPath *supportedFormatIndexPath = [self indexPathAtSection:VideoSettingsSectionSupportedFormats];
    BaseItemModel *format = [self modelWithIndex:supportedFormatIndexPath.row section:supportedFormatIndexPath.section];
    QBRTCVideoFormat *videoFormat = format.data;
    
    settings.videoFormat =
    [QBRTCVideoFormat videoFormatWithWidth:videoFormat.width
                                    height:videoFormat.height
                                 frameRate:frameRateSlider.currentValue
                               pixelFormat:QBRTCPixelFormat420f];
    [self reloadVideoFormatSectionForPosition:settings.preferredCameraPostion];
#endif
    [settings applyConfig];
    [settings saveToDisk];
    
}

@end
