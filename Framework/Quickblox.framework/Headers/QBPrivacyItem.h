//
//  QBPrivacyitem.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 8/15/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

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

#pragma mark -
#pragma mark - DEPRECATED

/**
 *  @warning Deprecated in 2.7.6. Use 'allow' instead.
 */
typedef NS_ENUM(NSUInteger, QBPrivacyAction) {
    
    QBPrivacyActionAllow,
    QBPrivacyActionDeny
} DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.6. Use 'allow' instead.");

/**
 *  @warning Deprecated in 2.7.4. Use QBPrivacyType instead.
 */
typedef enum QBPrivacyItemType {
    USER_ID = 1,
    GROUP_USER_ID,
    GROUP, // unsupported
    SUBSCRIPTION // unsupported
} QBPrivacyItemType DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use QBPrivacyType instead.");

/**
 *  @warning Deprecated in 2.7.4. Use QBPrivacyAction instead.
 */
typedef enum QBPrivacyItemAction {
    ALLOW,
    DENY,
} QBPrivacyItemAction DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use QBPrivacyAction instead.");

/**
 *  Action value to perform.
 *
 *  @see QBPrivacyAction.
 *
 *  @warning Deprecated in 2.7.6. Use 'allow' instead.
 */
@property (assign, nonatomic, readonly) QBPrivacyAction privacyAction DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.6. Use 'allow' instead.");

/**
 *  QBPrivacyItemType type value.
 *
 *  @warning Deprecated in 2.7.4. Use 'privacyType' instead.
 */
@property (assign, nonatomic, readonly) QBPrivacyItemType type DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'privacyType' instead.");

/**
 *  Action value to perform.
 *
 *  @warning Deprecated in 2.7.4. Use 'privacyAction' instead.
 */
@property (assign, nonatomic, readonly) QBPrivacyItemAction action DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'privacyAction' instead.");

/**
 *  Value for selected type.
 *
 *  @warning Deprecated in 2.7.6. Use 'userID' instead.
 */
@property (assign, nonatomic, readonly) NSUInteger valueForType DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.6. Use 'userID' instead.");

/**
 *  Init with type, value and action.
 *
 *  @param type         QBPrivacyItemType type value
 *  @param valueForType value for selected type
 *  @param action       QBPrivacyItemAction action value to perform
 *
 *  @warning Deprecated in 2.7.4. Use 'initWithPrivacyType:value:privacyAction:' instead.
 *
 *  @return QBPrivacyItem instance
 */
- (instancetype)initWithType:(QBPrivacyItemType)type valueForType:(NSUInteger)valueForType action:(QBPrivacyItemAction)action DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'initWithPrivacyType:value:privacyAction' instead.");

/**
 *  Init with privacy type, value and privacy action.
 *
 *  @param privacyType   QBPrivacyType privacy type value
 *  @param value         value for selected privacy type
 *  @param privacyAction QBPrivacyAction privacy action value
 *
 *  @warning Deprecated in 2.7.6. Use 'initWithPrivacyType:userID:privacyAction:mutualBlock:' instead.
 *
 *  @return QBPrivacyItem instance
 */
- (instancetype)initWithPrivacyType:(QBPrivacyType)privacyType
                       valueForType:(NSUInteger)valueForType
                      privacyAction:(QBPrivacyAction)privacyAction DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.6. Use 'initWithPrivacyType:userID:privacyAction:mutualBlock:' instead.");;

@end

NS_ASSUME_NONNULL_END
