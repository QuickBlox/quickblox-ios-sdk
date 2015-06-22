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
	GROUP,
	SUBSCRIPTION,
} QBPrivacyItemType;

typedef enum QBPrivacyItemAction {
    ALLOW,
    DENY,
} QBPrivacyItemAction;

#import "QBDDXMLElement.h"
/** QBPrivacyItem structure represents privacy object for managing privacy lists . */
@interface QBPrivacyItem : NSObject

/**
 @param type can be USER_ID, SUBSCRIPTION or GROUP
 @param valueForType value for type
 @param action can be ALLOW or DENY
 @return QBPrivacyItem instance
 */
- (instancetype)initWithType:(QBPrivacyItemType)type valueForType:(NSUInteger)valueForType action:(QBPrivacyItemAction)action;

/// type can be USER_ID, SUBSCRIPTION or GROUP
@property (assign) QBPrivacyItemType type;

/// valueForType value for type
@property (assign) NSUInteger valueForType;

/// action can be ALLOW or DENY
@property (assign) QBPrivacyItemAction action;

- (QBDDXMLElement *)convertToNSXMLElement;
@end


@interface QBDDXMLElement (QBPrivacyItem)

- (QBPrivacyItem *)convertToQBPrivacyItem;
@end
