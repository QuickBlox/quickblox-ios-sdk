//
//  CallSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Anton Sokolchenko on 12/1/15.
//  Copyright © 2015 QuickBlox Team. All rights reserved.
//

#import "CallSettingsViewController.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"
#import "SwitchItemModel.h"
#import "SampleCore.h"

@implementation CallSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	__weak __typeof([SampleCore settings])weakSettings = [SampleCore settings];
	
    [self addSection:SettingsSectionCallSettingsAnswerTimeInterval items:^NSArray *{
		SliderItemModel *slider = [[SliderItemModel alloc] initWithTitle:@"Answer time interval" minValue:10 maxValue:90 currentValue:weakSettings.answerTimeInterval];
		
		return @[slider];
	}];
	
	[self addSection:SettingsSectionCallSettingsDisconnectTimeInterval items:^NSArray *{
		SliderItemModel *slider = [[SliderItemModel alloc] initWithTitle:@"Disconnect time interval" minValue:10 maxValue:90 currentValue:weakSettings.disconnectTimeInterval];
		
		return @[slider];
	}];
	
	[self addSection:SettingsSectionCallSettingsDialingTimeInterval items:^NSArray *{
		SliderItemModel *slider = [[SliderItemModel alloc] initWithTitle:@"Dialing time interval" minValue:3 maxValue:15 currentValue:weakSettings.dialingTimeInterval];
		
		return @[slider];
	}];
	
	[self addSection:SettingsSectionCallSettingsDTLS items:^NSArray *{
		SwitchItemModel *switchItem = [[SwitchItemModel alloc] initWithTitle:@"DTLS" data:nil on:weakSettings.DTLSEnabled changedBlock:^(BOOL isOn) {
			weakSettings.DTLSEnabled = isOn;
		}];
		
		return @[switchItem];
	}];
	
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	Settings *settings = [SampleCore settings];
	
	SliderItemModel *answerSlider = self.sections[@(SettingsSectionCallSettingsAnswerTimeInterval)].items.firstObject;
	settings.answerTimeInterval = answerSlider.currentValue;
	
	SliderItemModel *disconnectSlider = self.sections[@(SettingsSectionCallSettingsDisconnectTimeInterval)].items.firstObject;
	settings.disconnectTimeInterval = disconnectSlider.currentValue;
	
	SliderItemModel *dialingSlider = self.sections[@(SettingsSectionCallSettingsDialingTimeInterval)].items.firstObject;
	settings.dialingTimeInterval = dialingSlider.currentValue;
}

- (NSString *)titleForSection:(SettingsSectionType)section {
    
	if (section == SettingsSectionCallSettingsAnswerTimeInterval) {
		return @"Answer time interval";
	} else if (section == SettingsSectionCallSettingsDisconnectTimeInterval) {
		return @"Disconnect time interval";
	} else if (section == SettingsSectionCallSettingsDialingTimeInterval) {
		return @"Dialing time interval";
	} else if (section == SettingsSectionCallSettingsDTLS) {
		return @"DTLS";
	}
	return [super titleForSection:section];
}

@end
