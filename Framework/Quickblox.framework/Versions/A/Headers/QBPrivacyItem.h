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


typedef enum QBPrivacyItemType {
	USER_ID = 1,
    GROUP_USER_ID,
	GROUP,
	SUBSCRIPTION
} QBPrivacyItemType;

typedef enum QBPrivacyItemAction {
    ALLOW,
    DENY,
} QBPrivacyItemAction;

@class DDXMLElement;
/** QBPrivacyItem structure represents privacy object for managing privacy lists . */
@interface QBPrivacyItem : NSObject

- (QB_NONNULL instancetype)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));;
+ (QB_NONNULL instancetype)new __attribute__((unavailable("'new' is not a supported initializer for this class.")));;

/**
 @param type can be USER_ID, SUBSCRIPTION, GROUP or GROUP_USER_ID
 @param valueForType value for type
 @param action can be ALLOW or DENY
 @return QBPrivacyItem instance
 */
- (QB_NONNULL instancetype)initWithType:(QBPrivacyItemType)type valueForType:(NSUInteger)valueForType action:(QBPrivacyItemAction)action;

/// type can be USER_ID, SUBSCRIPTION, GROUP OR GROUP_USER_ID( to block user in all group chats )
@property (assign, readonly) QBPrivacyItemType type;

/// valueForType value for type
@property (assign, readonly) NSUInteger valueForType;

/// action can be ALLOW or DENY
@property (assign, readonly) QBPrivacyItemAction action;

- (QB_NULLABLE DDXMLElement *)convertToNSXMLElementWithOrder:(NSUInteger) order;
@end
