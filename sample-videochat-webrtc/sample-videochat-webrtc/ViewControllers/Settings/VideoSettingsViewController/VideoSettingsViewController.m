//
//  SettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 21.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "VideoSettingsViewController.h"
#import "Settings.h"

#import "BaseSettingsCell.h"
#import "SettingCell.h"
#import "SettingSliderCell.h"
#import "SettingSwichCell.h"

#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"

typedef NS_ENUM(NSUInteger, VideoSettingsSectionType) {
    
    VideoSettingsSectionCameraPostion = 0,
    VideoSettingsSectionSupportedFormats = 1,
    VideoSettingsSectionRendererType = 2,
    VideoSettingsSectionVideoFrameRate = 3,
    VideoSettingsSectionBandwidth = 4
};

@interface VideoSettingsViewController () <UITableViewDataSource, UITableViewDelegate, SettingsCellDelegate>

@property (strong, nonatomic) Settings *settings;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSMutableDictionary *selectedIndexes;

@end

@implementation VideoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = Settings.instance;
    
    [self configure];
}

- (SettingsSectionModel *)sectionWith:(VideoSettingsSectionType)sectionType {
    
    NSString *title = [self titleForSection:sectionType];
    SettingsSectionModel *section = self.sections[title];
    return section;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    //APPLY SETTINGS
    
    //Preferred camera positon
    SwitchItemModel *cameraPostion = (id)[self modelWithIndex:0 section:VideoSettingsSectionCameraPostion];
    self.settings.preferredCameraPostion = cameraPostion.on ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    //Supported format
    NSIndexPath *supportedFormatIndexPath = [self indexPathAtSection:VideoSettingsSectionSupportedFormats];
    BaseItemModel *format = [self modelWithIndex:supportedFormatIndexPath.row section:supportedFormatIndexPath.section];
    QBRTCVideoFormat *videoFormat = format.data;
    
    //Frame rate
    SettingsSectionModel *frameRate = [self sectionWith:VideoSettingsSectionVideoFrameRate];
    SliderItemModel *frameRateSlider = frameRate.items.firstObject;

    //bandwidth
    SettingsSectionModel *bandwidth = [self sectionWith:VideoSettingsSectionBandwidth];
    SliderItemModel *bandwidthSlider = bandwidth.items.firstObject;
    
    self.settings.mediaConfiguration.videoBandwidth = bandwidthSlider.currentValue;
    
    NSIndexPath *videoRendererTypeIndexPath = [self indexPathAtSection:VideoSettingsSectionRendererType];
    
    self.settings.remoteVideoViewRendererType = videoRendererTypeIndexPath.row;
    
    self.settings.videoFormat =
    [QBRTCVideoFormat videoFormatWithWidth:videoFormat.width
                                 height:videoFormat.height
                              frameRate:frameRateSlider.currentValue
                            pixelFormat:QBRTCPixelFormat420f];
}

- (NSIndexPath *)indexPathAtSection:(VideoSettingsSectionType)section {
    
    NSString *key = [self titleForSection:section];
    NSIndexPath *indexPath = self.selectedIndexes[key];
    
    return indexPath;
}

- (BaseItemModel *)modelWithIndex:(NSUInteger)index section:(VideoSettingsSectionType)section {
    
    SettingsSectionModel *sectionModel = [self sectionWith:section];
    
    if (sectionModel.items.count == 0) {
        return nil;
    }
    
    SwitchItemModel *model = sectionModel.items[index];
    return model;
}

- (NSString *)titleForSection:(VideoSettingsSectionType)section {
    
    switch (section) {
            
        case VideoSettingsSectionCameraPostion: return @"Switch camera position";
        case VideoSettingsSectionSupportedFormats: return @"Video formats";
        case VideoSettingsSectionRendererType: return @"Renderer type";
        case VideoSettingsSectionVideoFrameRate: return @"Frame rate";
        case VideoSettingsSectionBandwidth: return @"Bandwidth";
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

- (SettingsSectionModel *)addSectionWith:(VideoSettingsSectionType)section items:(NSArray *(^)(NSString *sectionTitle))items {
    
    NSString *sectionTitle = [self titleForSection:section];
    SettingsSectionModel *sectionModel = [SettingsSectionModel sectionWithTitle:sectionTitle
                                                                            items:items(sectionTitle)];
    self.sections[sectionTitle] = sectionModel;
    
    return sectionModel;
}

- (void)selectSection:(VideoSettingsSectionType)section index:(NSUInteger)index {
    
    if (index == NSNotFound) {
        index = 0;
    }
    
    NSString *sectionTitle = [self titleForSection:section];
    NSIndexPath *supportedFormatsIndexPath = [NSIndexPath indexPathForRow:index inSection:section];
    self.selectedIndexes[sectionTitle] = supportedFormatsIndexPath;
}

- (NSArray *)configure {
    
    self.selectedIndexes = [NSMutableDictionary dictionary];
    self.sections = [NSMutableDictionary dictionary];
    
    NSMutableArray *sections = [NSMutableArray array];

    //Camera position section
    __weak __typeof(self)weakSelf = self;
    [self addSectionWith:VideoSettingsSectionCameraPostion items:^NSArray *(NSString *sectionTitle) {
        
        //Camera position section
        SwitchItemModel *switchItem = [[SwitchItemModel alloc] init];
        switchItem.title = @"Back Camera";

        switchItem.on = (weakSelf.settings.preferredCameraPostion == AVCaptureDevicePositionBack);
        
        return @[switchItem];
    }];
    //Supported video formats section
    [self addSectionWith:VideoSettingsSectionSupportedFormats items:^NSArray *(NSString *sectionTitle) {
        
        AVCaptureDevicePosition position = weakSelf.settings.preferredCameraPostion;
        NSArray *videoFormats = [weakSelf videoFormatModelsWithCameraPositon:position];
        
        NSArray *formats = [QBRTCCameraCapture formatsWithPosition:position];
        //Select index path
        NSUInteger idx = [formats indexOfObject:weakSelf.settings.videoFormat];
        [weakSelf selectSection:VideoSettingsSectionSupportedFormats index:idx];
        
        return videoFormats;
    }];
    //Remote video renderer type
    [self addSectionWith:VideoSettingsSectionRendererType items:^NSArray *(NSString *sectionTitle) {
        
        BaseItemModel *rendererTypeSampleBuffer = [[BaseItemModel alloc] init];
        rendererTypeSampleBuffer.title = @"CMSampleBuffer";
        
        BaseItemModel *rendererTypeEAGL = [[BaseItemModel alloc] init];
        rendererTypeEAGL.title = @"EAGL";
        
        NSString *rendererTypeKey = [weakSelf titleForSection:VideoSettingsSectionRendererType];
        NSIndexPath *rendererTypeIndexPath = [NSIndexPath indexPathForRow:weakSelf.settings.remoteVideoViewRendererType
                                                                inSection:VideoSettingsSectionRendererType];
        weakSelf.selectedIndexes[rendererTypeKey] = rendererTypeIndexPath;
        
        return @[rendererTypeSampleBuffer, rendererTypeEAGL];
    }];
    //Frame rate
    [self addSectionWith:VideoSettingsSectionVideoFrameRate items:^NSArray *(NSString *sectionTitle) {
        
        SliderItemModel *frameRateSlider = [[SliderItemModel alloc] init];
        frameRateSlider.title = @"30";
        frameRateSlider.minValue = 2;
        frameRateSlider.currentValue = weakSelf.settings.videoFormat.frameRate;
        frameRateSlider.maxValue = 30;
        
        return @[frameRateSlider];
    }];
    //Video bandwidth
    [self addSectionWith:VideoSettingsSectionBandwidth items:^NSArray *(NSString *sectionTitle) {
        
        SliderItemModel *bandwidthSlider = [[SliderItemModel alloc] init];
        bandwidthSlider.title = @"30";
        bandwidthSlider.minValue = 0;
        bandwidthSlider.currentValue = weakSelf.settings.mediaConfiguration.videoBandwidth;
        bandwidthSlider.maxValue = 2000;
        
        return @[bandwidthSlider];
    }];
    
    return sections;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    SettingsSectionModel *sectionItem = [self sectionWith:section];
    return sectionItem.title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    SettingsSectionModel *sectionItem = [self sectionWith:section];
    return sectionItem.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingsSectionModel *sectionItem = [self sectionWith:indexPath.section];
    BaseItemModel *itemModel = sectionItem.items[indexPath.row];
    
    BaseSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(itemModel.viewClass)];
    
    NSString *key = [self titleForSection:indexPath.section];
    
    NSIndexPath *selectedIndexPath = self.selectedIndexes[key];
    cell.accessoryType = [indexPath compare:selectedIndexPath] == NSOrderedSame ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    cell.delegate = self;
    cell.model = itemModel;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case VideoSettingsSectionSupportedFormats:
        case VideoSettingsSectionRendererType: {
            
            NSString *key = [self titleForSection:indexPath.section];
            NSIndexPath *previosIndexPath = self.selectedIndexes[key];
            
            if ([indexPath compare:previosIndexPath] == NSOrderedSame) {
                return;
            }
            self.selectedIndexes[key] = indexPath.copy;
            
            [self.tableView reloadRowsAtIndexPaths:@[previosIndexPath, indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

#pragma mark - SettingsCellDelegate

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model {
    
    if ([model isKindOfClass:[SwitchItemModel class]]) {
        
        AVCaptureDevicePosition position = ((SwitchItemModel *)model).on ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        NSArray *videoFormatModels = [self videoFormatModelsWithCameraPositon:position];
        
        SettingsSectionModel *section = [self sectionWith:VideoSettingsSectionSupportedFormats];
        section.items = videoFormatModels;
        
        NSArray *formats = [QBRTCCameraCapture formatsWithPosition:position];
        
        NSString *title = [self titleForSection:VideoSettingsSectionSupportedFormats];
        NSIndexPath *oldIdnexPath = self.selectedIndexes[title];
        //Select index path
        
        NSUInteger idx = section.items.count-1;
        
        if (idx >= oldIdnexPath.row) {
            
            BaseItemModel *videoFormatModel = section.items[oldIdnexPath.row];
            QBRTCVideoFormat *videoFormat = videoFormatModel.data;
            
            idx = [formats indexOfObject:videoFormat];
        }
        
        [self selectSection:VideoSettingsSectionSupportedFormats index:idx];
        
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndex:VideoSettingsSectionSupportedFormats];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
