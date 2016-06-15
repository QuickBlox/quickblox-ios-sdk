//
//  QBPrivacyList.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 8/19/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBPrivacyItem;

/**
 *  QBPrivacyList class interface.
 *  This class structure represents collection for storing objects of QBPrivacyItem type.
 */
@interface QBPrivacyList : NSObject

// unavailable initializers
- (QB_NULLABLE instancetype)init NS_UNAVAILABLE;
+ (QB_NULLABLE instancetype)new NS_UNAVAILABLE;

/**
 *  Init with name.
 *
 *  @param name name of privacy list
 *
 *  @note Name must contain at least one character.
 *
 *  @return QBPrivacyList instance
 */
- (QB_NONNULL instancetype)initWithName:(QB_NONNULL NSString *)name;

/**
 *  Init with name and items.
 *
 *  @param name  name of privacy list
 *  @param items array of privacy items
 *
 *  @note This is designated initializer. Name must contain at least one character.
 *
 *  @return QBPrivacyList instance
 */
- (QB_NONNULL instancetype)initWithName:(QB_NONNULL NSString *)name items:(QB_NULLABLE NSArray QB_GENERIC(QBPrivacyItem *) *)items NS_DESIGNATED_INITIALIZER;

/**
 *  Add privacy item object.
 *
 *  @param privacyItem QBPrivacyItem privacy item instance
 */
- (void)addObject:(QB_NONNULL QBPrivacyItem *)privacyItem;

/**
 *  Name of privacy list.
 */
@property (copy, QB_NONNULL_PROPERTY) NSString *name;

/**
 *  Items array of privacy items.
 *
 *  @warning Deprecated in 2.7.4. Use 'privacyItems' instead.
 */
@property (strong, QB_NONNULL_PROPERTY) NSMutableArray QB_GENERIC(QBPrivacyItem *) *items DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'privacyItems' instead.");

/**
 *  Privacy items array.
 */
@property (strong, QB_NONNULL_PROPERTY) NSArray QB_GENERIC(QBPrivacyItem *) *privacyItems;

/**
 *  Count of items in list.
 *
 *  @warning Deprecated in 2.7.4. Use 'privacyItems.count' instead.
 *
 *  @return count of items
 */
- (NSUInteger)count DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'privacyItems.count' instead.");

@end
