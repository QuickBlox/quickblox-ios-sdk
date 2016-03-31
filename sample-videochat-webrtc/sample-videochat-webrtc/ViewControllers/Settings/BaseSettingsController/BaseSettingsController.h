//
// Created by Anton Sokolchenko on 11/30/15.
// Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseSettingsCell.h"
#import "Settings.h"

@class BaseItemModel;
@class SettingsSectionModel;

typedef NS_ENUM(NSUInteger, SettingsSectionType) {

    VideoSettingsSectionCameraPosition = 0,
    VideoSettingsSectionSupportedFormats,
    VideoSettingsSectionVideoFrameRate,
    VideoSettingsSectionBandwidth,
    SettingsSectionAudioCodec,
	SettingsSectionStun,
	SettingsSectionListOfUsers,
	SettingsSectionCallSettingsAnswerTimeInterval,
	SettingsSectionCallSettingsDisconnectTimeInterval,
	SettingsSectionCallSettingsDialingTimeInterval,
	SettingsSectionCallSettingsDTLS,
	SettingsSectionNumSections
};

@interface BaseSettingsController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary<NSNumber *, SettingsSectionModel *> *sections;

- (void)addSection:(SettingsSectionType)section items:(NSArray *(^)())items;
- (void)addSection:(SettingsSectionType)section item:(BaseItemModel *)item;
- (NSString *)titleForSection:(SettingsSectionType)section;

@end