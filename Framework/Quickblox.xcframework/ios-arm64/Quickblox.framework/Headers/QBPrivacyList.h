//
//  QBPrivacyList.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBPrivacyItem;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBPrivacyList class interface.
 *  This class structure represents collection for storing objects of QBPrivacyItem type.
 */
@interface QBPrivacyList : NSObject

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Init with name.
 *
 *  @param name name of privacy list
 *
 *  @note Name must contain at least one character.
 *
 *  @return QBPrivacyList instance
 */
- (instancetype)initWithName:(NSString *)name;

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
- (instancetype)initWithName:(NSString *)name items:(nullable NSArray<QBPrivacyItem *> *)items NS_DESIGNATED_INITIALIZER;

/**
 *  Add privacy item object.
 *
 *  @param privacyItem QBPrivacyItem privacy item instance
 */
- (void)addObject:(QBPrivacyItem *)privacyItem;

/**
 *  Name of privacy list.
 */
@property (nonatomic, copy) NSString *name;

/**
 *  Privacy items array.
 */
@property (nonatomic, copy) NSArray<QBPrivacyItem *> *privacyItems;

@end

NS_ASSUME_NONNULL_END
