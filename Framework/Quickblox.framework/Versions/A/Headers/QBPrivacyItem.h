//
//  QBPrivacyitem.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 8/15/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum QBPrivacyItemType {
	USER_ID,
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

/**
 @param type can be USER_ID, SUBSCRIPTION, GROUP or GROUP_USER_ID
 @param valueForType value for type
 @param action can be ALLOW or DENY
 @return QBPrivacyItem instance
 */
- (instancetype)initWithType:(QBPrivacyItemType)type valueForType:(NSUInteger)valueForType action:(QBPrivacyItemAction)action;

/// type can be USER_ID, SUBSCRIPTION, GROUP OR GROUP_USER_ID( to block user in all group chats )
@property (assign) QBPrivacyItemType type;

/// valueForType value for type
@property (assign) NSUInteger valueForType;

/// action can be ALLOW or DENY
@property (assign) QBPrivacyItemAction action;

- (DDXMLElement *)convertToNSXMLElementWithOrder:(NSUInteger) order;
@end
