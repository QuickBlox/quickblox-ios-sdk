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

/**
 *  @warning Deprecated in 2.7.4. Use QBPrivacyType instead.
 */
typedef enum QBPrivacyItemType {
    USER_ID = 1,
    GROUP_USER_ID,
    GROUP,
    SUBSCRIPTION
} QBPrivacyItemType DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use QBPrivacyType instead.");

/**
 *  @warning Deprecated in 2.7.4. Use QBPrivacyAction instead.
 */
typedef enum QBPrivacyItemAction {
    ALLOW,
    DENY,
} QBPrivacyItemAction DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use QBPrivacyAction instead.");

typedef NS_ENUM(NSUInteger, QBPrivacyType) {
    
    QBPrivacyTypeUserID = 1,
    QBPrivacyTypeGroupUserID,
    QBPrivacyTypeGroup,
    QBPrivacyTypeSubscription
};

typedef NS_ENUM(NSUInteger, QBPrivacyAction) {
    
    QBPrivacyActionAllow,
    QBPrivacyActionDeny
};

/**
 *  QBPrivacyItem class interface.
 *  This class structure represents privacy object for managing privacy lists.
 */
@interface QBPrivacyItem : NSObject

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
 *  QBPrivacyItemType type value.
 */
@property (assign, nonatomic, readonly) QBPrivacyType privacyType;

/**
 *  Value for selected type.
 */
@property (assign, nonatomic, readonly) NSUInteger valueForType;

/**
 *  Action value to perform.
 */
@property (assign, nonatomic, readonly) QBPrivacyAction privacyAction;

// unavailable initializers
- (QB_NULLABLE instancetype)init NS_UNAVAILABLE;
+ (QB_NULLABLE instancetype)new NS_UNAVAILABLE;

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
- (QB_NONNULL instancetype)initWithType:(QBPrivacyItemType)type valueForType:(NSUInteger)valueForType action:(QBPrivacyItemAction)action DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.4. Use 'initWithPrivacyType:value:privacyAction' instead.");

/**
 *  Init with privacy type, value and privacy action.
 *
 *  @param privacyType   QBPrivacyType privacy type value
 *  @param value         value for selected privacy type
 *  @param privacyAction QBPrivacyAction privacy action value
 *
 *  @return QBPrivacyItem instance
 */
- (QB_NULLABLE instancetype)initWithPrivacyType:(QBPrivacyType)privacyType
                                   valueForType:(NSUInteger)valueForType
                                  privacyAction:(QBPrivacyAction)privacyAction;

@end
