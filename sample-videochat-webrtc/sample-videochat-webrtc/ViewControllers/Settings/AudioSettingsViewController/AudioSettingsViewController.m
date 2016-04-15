//
//  AudioSettingsViewController.m
//  sample-videochat-webrtc
//
//  Created by Andrey Ivanov on 25.06.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "AudioSettingsViewController.h"
#import "Settings.h"
#import "SettingsSectionModel.h"
#import "SampleCore.h"

@implementation AudioSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addSection:SettingsSectionAudioCodec items:^NSArray * {
        
        BaseItemModel *opus = [[BaseItemModel alloc] initWithTitle:@"Opus" data:@(QBRTCAudioCodecOpus)];
        BaseItemModel *isac = [[BaseItemModel alloc] initWithTitle:@"ISAC" data:@(QBRTCAudioCodecISAC)];
        BaseItemModel *iLBC = [[BaseItemModel alloc] initWithTitle:@"iLBC" data:@(QBRTCAudioCodeciLBC)];

        return @[opus, isac, iLBC];
    }];
	

    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	BaseItemModel *item = self.sections[@(indexPath.section)].items[indexPath.row];
	
    BOOL isCheckmark = [(NSNumber *) item.data isEqualToNumber:@([SampleCore settings].mediaConfiguration.audioCodec)];
    cell.accessoryType = isCheckmark ?  UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BaseItemModel *item = self.sections[@(indexPath.section)].items[indexPath.row];
    [SampleCore settings].mediaConfiguration.audioCodec = (QBRTCAudioCodec) [(NSNumber *) item.data unsignedIntegerValue];

    [tableView reloadData];
}

@end
