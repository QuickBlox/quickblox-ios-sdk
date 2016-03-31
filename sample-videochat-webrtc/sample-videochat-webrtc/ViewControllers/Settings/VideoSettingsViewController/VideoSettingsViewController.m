//
//  SettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 21.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "VideoSettingsViewController.h"
#import "Settings.h"
#import "SettingsSectionModel.h"

#import "BaseSettingsCell.h"
#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "BaseSettingsController.h"
#import "SampleCore.h"

@implementation VideoSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configure];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //APPLY SETTINGS
    
    //Frame rate
    SettingsSectionModel *frameRate = self.sections[@(VideoSettingsSectionVideoFrameRate)];
    SliderItemModel *frameRateSlider = frameRate.items.firstObject;
	[SampleCore settings].videoFormat.frameRate = frameRateSlider.currentValue;
	
    //bandwidth
    SettingsSectionModel *bandwidth = self.sections[@(VideoSettingsSectionBandwidth)];
    SliderItemModel *bandwidthSlider = bandwidth.items.firstObject;
    
    [SampleCore settings].mediaConfiguration.videoBandwidth = bandwidthSlider.currentValue;
}

- (NSArray *)videoFormatModelsWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    //Grab supported formats
    NSArray *formats = [QBRTCCameraCapture formatsWithPosition:cameraPosition];

    NSMutableArray *videoFormatModels = [NSMutableArray arrayWithCapacity:formats.count];
    for(QBRTCVideoFormat *videoFormat in formats) {

        BaseItemModel *videoFormatModel = [[BaseItemModel alloc] init];
        videoFormatModel.title = [NSString stringWithFormat:@"%tux%tu", videoFormat.width, videoFormat.height];
        videoFormatModel.data = videoFormat;
        [videoFormatModels addObject:videoFormatModel];
    }

    return videoFormatModels;
}

- (void)configure {

    //Camera position section
    __weak __typeof(self)weakSelf = self;

    [self addSection:VideoSettingsSectionCameraPosition item:[[SwitchItemModel alloc] initWithTitle:@"Back Camera" data:nil on:([SampleCore settings].preferredCameraPosition == AVCaptureDevicePositionBack) changedBlock:^(BOOL isOn){
		__typeof(self)strongSelf = weakSelf;
        AVCaptureDevicePosition position = isOn ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
		
		[SampleCore settings].preferredCameraPosition = position;
		
        SettingsSectionModel *section = strongSelf.sections[@(VideoSettingsSectionSupportedFormats)];
        section.items = [strongSelf videoFormatModelsWithCameraPosition:position];

        NSArray *formats = [QBRTCCameraCapture formatsWithPosition:position];
		
		BOOL previousFormatExistsInNewCollection = NO;
		for (QBRTCVideoFormat *format in formats) {
			if ([[SampleCore settings].videoFormat isEqual:format]) {
				previousFormatExistsInNewCollection = YES;
			}
		}
		
		if (!previousFormatExistsInNewCollection) {
			[SampleCore settings].videoFormat = formats[0];
		}
		
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndex:VideoSettingsSectionSupportedFormats];
		
        [strongSelf.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }]];
    //Supported video formats section
    [self addSection:VideoSettingsSectionSupportedFormats items:^NSArray *() {

        AVCaptureDevicePosition position = [SampleCore settings].preferredCameraPosition;
        NSArray *videoFormats = [weakSelf videoFormatModelsWithCameraPosition:position];

        return videoFormats;
    }];
    //Frame rate
    [self addSection:VideoSettingsSectionVideoFrameRate item:[[SliderItemModel alloc] initWithMinValue:2 maxValue:30 currentValue:[SampleCore settings].videoFormat.frameRate]];

    //Video bandwidth
    [self addSection:VideoSettingsSectionBandwidth item:[[SliderItemModel alloc] initWithMinValue:0 maxValue:2000 currentValue:[SampleCore settings].mediaConfiguration.videoBandwidth]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	BaseSettingsCell *cell = (BaseSettingsCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	BaseItemModel *item = cell.model;
	
	BOOL isCheckmark = NO;
	
	switch (indexPath.section) {
		case VideoSettingsSectionSupportedFormats:
			isCheckmark = [(QBRTCVideoFormat *) item.data isEqual:[SampleCore settings].videoFormat];
			break;
		default:
			break;
	}
	
    cell.accessoryType = isCheckmark ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
		case VideoSettingsSectionSupportedFormats: {
            
			BaseSettingsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			BaseItemModel *item =  cell.model;
			[SampleCore settings].videoFormat = (QBRTCVideoFormat *) item.data;
		}
			break;
        default:
			break;
    }
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
