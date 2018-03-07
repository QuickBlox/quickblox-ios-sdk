//
//  QBPrivacyitem.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBPrivacyType) {
    
    QBPrivacyTypeUserID = 1,
    QBPrivacyTypeGroupUserID
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBPrivacyItem class interface.
 *  This class structure represents privacy object for managing privacy lists.
 */
@interface QBPrivacyItem : NSObject

/**
 *  QBPrivacyItemType type value.
 *
 *  @see QBPrivacyItemType.
 */
@property (assign, nonatomic, readonly) QBPrivacyType privacyType;

/**
 *  User ID.
 */
@property (assign, nonatomic, readonly) NSUInteger userID;

/**
 *  Determines whether item's action is allow or deny.
 */
@property (assign, nonatomic, readonly, getter=isAllowed) BOOL allow;

/**
 *  Determines whether block is mutual.
 *
 *  @discussion By default user, who is blocking, can send messages and presences to
 *  the one he blocked without any errors. To achieve a two-way block set this
 *  property to YES. After that the user, who is blocking, will receive errors
 *  when will try to communicate with blocked user.
 */
@property (assign, nonatomic) BOOL mutualBlock;

// unavailable initializers
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Init with privacy type, userID and privacy action.
 *
 *  @param privacyType   QBPrivacyType value (user ID, group user ID, subscription)
 *  @param userID        user ID
 *  @param allow         determines whether action is to allow or deny user
 *
 *  @return QBPrivacyItem instance
 */
- (nullable instancetype)initWithPrivacyType:(QBPrivacyType)privacyType
                                      userID:(NSUInteger)userID
                                       allow:(BOOL)allow;

@end

NS_ASSUME_NONNULL_END
