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

/// QBPrivacyList class represents collection for storing objects of QBPrivacyItem type
@interface QBPrivacyList : NSObject

- (QB_NONNULL instancetype)init __attribute__((unavailable("init not available")));

/**
 @param name name of privacy list, must contain at least one character
 @return QBPrivacyList instance
 */
- (QB_NONNULL instancetype)initWithName:(QB_NONNULL NSString *)name;

/**
 @param items array of QBPrivacyItems
 @param name name of privacy list, must contain at least one character
 @return QBPrivacyList instance
 */
- (QB_NONNULL instancetype)initWithName:(QB_NONNULL NSString *)name items:(QB_NULLABLE NSArray QB_GENERIC(QBPrivacyItem *) *)items NS_DESIGNATED_INITIALIZER;

/// add object to items array
/// @param privacyItem privacy item
- (void)addObject:(QB_NONNULL QBPrivacyItem *)privacyItem;

/// name of privacy list
@property (copy, QB_NONNULL_PROPERTY) NSString *name;

/// items array of privacy items
@property (strong, QB_NONNULL_PROPERTY) NSMutableArray QB_GENERIC(QBPrivacyItem *) *items;

/// count of items in list
- (NSUInteger)count;

@end
