//
//  QBPrivacyList.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 8/19/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBPrivacyItem;

/// QBPrivacyList class represents collection for storing objects of QBPrivacyItem type
@interface QBPrivacyList : NSObject

- (instancetype)init __attribute__((unavailable("init not available")));

/**
 @param name name of privacy list, must contain at least one character
 @return QBPrivacyList instance
 */
- (instancetype)initWithName:(NSString *)name;

/**
 @param items array of QBPrivacyItems
 @param name name of privacy list, must contain at least one character
 @return QBPrivacyList instance
 */
- (instancetype)initWithName:(NSString *)name items:(NSArray *)items NS_DESIGNATED_INITIALIZER;

/// add object to items array
/// @param privacyItem privacy item
- (void)addObject:(QBPrivacyItem *)privacyItem;

/// name of privacy list
@property (copy) NSString *name;

/// items array of privacy items
@property (retain) NSMutableArray *items;

/// count of items in list
- (NSUInteger)count;

@end
