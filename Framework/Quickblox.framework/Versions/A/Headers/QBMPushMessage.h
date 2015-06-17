//
//  QBMPushMessage.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBMPushMessageBase.h"

/** QBMPushMessage class declaration. */
/** Overview */
/** Push message representation. */

/** Push message representation.
 @see http://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ApplePushService/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1 */

@interface QBMPushMessage : QBMPushMessageBase <NSCoding, NSCopying>{
	NSString *alertBody;
	NSNumber *badge;
	NSString *soundFile;
	NSString *localizedBodyKey;
	NSArray *localizedBodyArguments;
	NSString *localizedActionKey;
	NSDictionary *additionalInfo;
}
/** Alert body text */
@property (nonatomic,retain) NSString *alertBody;

/** Badge number */
@property (nonatomic,retain) NSNumber *badge;

/** Sound file name */
@property (nonatomic,retain) NSString *soundFile;

/** Localized body key may be used instead of alert body to make push message appear on local language. */
@property (nonatomic,retain) NSString *localizedBodyKey;

/** Substitute strings for placeholders in alert text */
@property (nonatomic,retain) NSArray *localizedBodyArguments;

/** Localization key for name of the alert action button */
@property (nonatomic,retain) NSString *localizedActionKey;

/** Dictionary of additional information */
@property (nonatomic,retain) NSDictionary *additionalInfo;

/** Create new push message
 @return New instance of QBMPushMessage
 */
+ (QBMPushMessage *)pushMessage;
@end