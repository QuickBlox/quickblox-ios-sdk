//
//  BaseSettingsViewController.m
//  sample-videochat-webrtc-old
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "BaseSettingsViewController.h"

#import "Settings.h"

#import "SettingCell.h"
#import "SettingSliderCell.h"
#import "SettingSwitchCell.h"

#import "SwitchItemModel.h"
#import "SliderItemModel.h"
#import "SettingsSectionModel.h"

@implementation BaseSettingsViewController

// MARK: Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = [Settings instance];
    self.selectedIndexes = [NSMutableDictionary dictionary];
    self.sections = [NSMutableDictionary dictionary];
    
    [self configure];
    [self registerNibs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self applySettings];
}

// MARK: Public

- (SettingsSectionModel *)sectionWith:(NSUInteger)sectionType {
    
    NSString *title = [self titleForSection:sectionType];
    SettingsSectionModel *section = self.sections[title];
    return section;
}

- (NSIndexPath *)indexPathAtSection:(NSUInteger)section {
    
    NSString *key = [self titleForSection:section];
    NSIndexPath *indexPath = self.selectedIndexes[key];
    
    return indexPath;
}

- (BaseItemModel *)modelWithIndex:(NSUInteger)index section:(NSUInteger)section {
    
    SettingsSectionModel *sectionModel = [self sectionWith:section];
    
    if (sectionModel.items.count == 0) {
        return nil;
    }
    
    BaseItemModel *model = sectionModel.items[index];
    return model;
}

- (SettingsSectionModel *)addSectionWith:(NSUInteger)section items:(NSArray *(^)(NSString *sectionTitle))items {
    
    NSString *sectionTitle = [self titleForSection:section];
    SettingsSectionModel *sectionModel = [SettingsSectionModel sectionWithTitle:sectionTitle
                                                                          items:items(sectionTitle)];
    self.sections[sectionTitle] = sectionModel;
    
    return sectionModel;
}

- (void)selectSection:(NSUInteger)section index:(NSUInteger)index {
    
    if (index == NSNotFound) {
        index = 0;
    }
    
    NSString *sectionTitle = [self titleForSection:section];
    NSIndexPath *supportedFormatsIndexPath = [NSIndexPath indexPathForRow:index inSection:section];
    self.selectedIndexes[sectionTitle] = supportedFormatsIndexPath;
}

- (void)updateSelectionAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = [self titleForSection:indexPath.section];
    NSIndexPath *previosIndexPath = self.selectedIndexes[key];
    
    if ([indexPath compare:previosIndexPath] == NSOrderedSame) {
        return;
    }
    self.selectedIndexes[key] = indexPath.copy;
    
    [self.tableView reloadRowsAtIndexPaths:@[previosIndexPath, indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
}

// MARK: Override

- (void)configure {
    
    NSAssert(nil, @"Must be overriden in superclass.");
}

- (void)applySettings {
    
    NSAssert(nil, @"Must be overriden in superclass.");
}

- (NSString *)titleForSection:(NSUInteger)section {
    
    NSAssert(nil, @"Must be overriden in superclass.");
    
    return nil;
}

// MARK: UITableViewDataSource

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

// MARK: SettingsCellDelegate

- (void)cell:(BaseSettingsCell *)cell didChageModel:(BaseItemModel *)model {
    
    NSAssert(nil, @"Required method of SettingsCellDelegate must be implemented in superclass.");
}

// Private:

- (void)registerNibs {
    
    [self.tableView registerNib:[SettingCell nib] forCellReuseIdentifier:[SettingCell identifier]];
    [self.tableView registerNib:[SettingSwitchCell nib] forCellReuseIdentifier:[SettingSwitchCell identifier]];
    [self.tableView registerNib:[SettingSliderCell nib] forCellReuseIdentifier:[SettingSliderCell identifier]];
}

@end
