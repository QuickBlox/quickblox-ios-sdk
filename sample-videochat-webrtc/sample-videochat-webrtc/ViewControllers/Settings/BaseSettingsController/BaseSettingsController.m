//
// Created by Anton Sokolchenko on 11/30/15.
// Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "BaseSettingsController.h"
#import "SettingsSectionModel.h"
#import "Settings.h"
#import "SettingSliderCell.h"
#import "SettingSwitchCell.h"

@implementation BaseSettingsController

- (instancetype)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		[self initialSetup];
		[self.tableView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
		
		[self.tableView registerNib:[UINib nibWithNibName:@"SettingSliderCell" bundle:nil] forCellReuseIdentifier:@"SettingSliderCell"];
		
		[self.tableView registerNib:[UINib nibWithNibName:@"SettingSwitchCell" bundle:nil] forCellReuseIdentifier:@"SettingSwitchCell"];
		
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialSetup];
	}
	return self;
}

- (void)initialSetup {
	self.sections = [NSMutableDictionary dictionary];
	self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)addSection:(SettingsSectionType)section items:(NSArray *(^)())items {
    NSCAssert(self.sections != nil, @"Uninitialized sections");

    NSString *sectionTitle = [self titleForSection:section];
    SettingsSectionModel *sectionModel = [SettingsSectionModel sectionWithTitle:sectionTitle
            items:items() type:section];
	self.sections[@(section)] = sectionModel;
}

- (void)addSection:(SettingsSectionType)section item:(BaseItemModel *)item {
    [self addSection:section items:^NSArray * {
        return @[item];
    }];
}

- (NSString *)titleForSection:(SettingsSectionType)section {

    switch (section) {

        case VideoSettingsSectionCameraPosition: return @"Switch camera position";
        case VideoSettingsSectionSupportedFormats: return @"Video formats";
        case VideoSettingsSectionVideoFrameRate: return @"Frame rate";
        case SettingsSectionListOfUsers: return @"List of users";
        case VideoSettingsSectionBandwidth: return @"Bandwidth";
        case SettingsSectionAudioCodec: return @"Audio codecs";
        case SettingsSectionStun: return @"Servers list";
            
        default: NSParameterAssert(false);break;
    }
    NSParameterAssert(false);
    return nil;
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return SettingsSectionNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    SettingsSectionModel *sectionItem = self.sections[@(section)];
    return sectionItem.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SettingsSectionModel *section = self.sections[@(indexPath.section)];
    BaseItemModel *item = section.items[indexPath.row];

	NSCAssert(item != nil, @"No item at indexPath");
	
    BaseSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(item.viewClass) forIndexPath:indexPath];

    cell.model = item;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    SettingsSectionModel *sectionItem = self.sections[@(section)];
    return sectionItem.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0 ||
		[[self titleForSection:section] isEqualToString:@""]) {
		
		return 0.01f; // return 0 does NOT work, known bug
	}
	return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
		
		return 0.01f; // return 0 does NOT work, known bug
	}
	return [super tableView:tableView heightForFooterInSection:section];
}


@end