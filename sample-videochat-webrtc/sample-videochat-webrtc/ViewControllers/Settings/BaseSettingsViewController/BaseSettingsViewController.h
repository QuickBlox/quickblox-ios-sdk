//
//  BaseSettingsViewController.h
//  sample-videochat-webrtc-old
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseSettingsCell.h"

@class Settings;
@class SettingsSectionModel;

NS_ASSUME_NONNULL_BEGIN

@interface BaseSettingsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, SettingsCellDelegate>

// MARK: Properties

/**
 *  Settings storage.
 *
 *  @see Settings
 */
@property (strong, nonatomic) Settings *settings;

/**
 *  Sections models.
 */
@property (strong, nonatomic) NSMutableDictionary *sections;

/**
 *  Selected indexes for each section.
 */
@property (strong, nonatomic) NSMutableDictionary *selectedIndexes;

// MARK: Public methods

/**
 *  Settings section model for section index
 *
 *  @param sectionType section index
 *
 *  @return Settings section model
 */
- (SettingsSectionModel *)sectionWith:(NSUInteger)sectionType;

/**
 * Index path for section index.
 *
 *  @param section Section index
 *
 *  @return Index path for section index
 */
- (NSIndexPath *)indexPathAtSection:(NSUInteger)section;

/**
 *  Model for section with index.
 *
 *  @param index model index
 *  @param section section index
 *
 *  @return model for section
 */
- (BaseItemModel *)modelWithIndex:(NSUInteger)index section:(NSUInteger)section;

/**
 *  Add section with index and items.
 *
 *  @param section section index
 *  @param items items for section
 *
 *  @return settings section model
 */
- (SettingsSectionModel *)addSectionWith:(NSUInteger)section items:(NSArray *(^)(NSString *sectionTitle))items;

/**
 *  Select item at section.
 *
 *  @param section section index
 *  @param index item index
 */
- (void)selectSection:(NSUInteger)section index:(NSUInteger)index;

/**
 *  Update selection by selecting a new item and deselecting old one.
 *
 *  @param indexPath index path of requested item
 */
- (void)updateSelectionAtIndexPath:(NSIndexPath *)indexPath;

// MARK: Override
// @note Methods down below are required to be implemented by superclass.

/**
 *  Configure your section by using '-addSectionWith:items:' method here.
 *
 *  @note Method is called on '-viewDidLoad:'. Should not be called directly.
 */
- (void)configure;

/**
 *  Apply your settings here.
 *
 *  @discussion Apply settings to settings storage by overriding this method. Can be called directly.
 *
 *  @note By default called on '-viewWillDisappear:'.
 */
- (void)applySettings;

/**
 *  Title for section.
 *
 *  @param section section index
 *
 *  @return Title string
 */
- (NSString *)titleForSection:(NSUInteger)section;

@end

NS_ASSUME_NONNULL_END
