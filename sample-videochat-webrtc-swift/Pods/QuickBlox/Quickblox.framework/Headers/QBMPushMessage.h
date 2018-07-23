//
//  QBMPushMessage.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Quickblox/QBMPushMessageBase.h>

NS_ASSUME_NONNULL_BEGIN

/** QBMPushMessage class interface.
 *  Push message representation.
 *
 *  @see http://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/ApplePushService/ApplePushService.html#//apple_ref/doc/uid/TP40008194-CH100-SW1 
 */
@interface QBMPushMessage : QBMPushMessageBase <NSCoding, NSCopying>

/** 
 *  Alert body text.
 */
@property (nonatomic, copy, nullable) NSString *alertBody;

/** 
 *  Badge number.
 */
@property (nonatomic, strong, nullable) NSNumber *badge;

/** 
 *  Sound file name.
 */
@property (nonatomic, copy, nullable) NSString *soundFile;

/** 
 *  Localized body key may be used instead of alert body to make push message appear on local language.
 */
@property (nonatomic, copy, nullable) NSString *localizedBodyKey;

/** 
 *  Substitute strings for placeholders in alert text.
 */
@property (nonatomic, copy, nullable) NSArray *localizedBodyArguments;

/**
 *  Localization key for name of the alert action button.
 */
@property (nonatomic, copy, nullable) NSString *localizedActionKey;

/** 
 *  Dictionary of additional information.
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *additionalInfo;

/** 
 *  Create new push message.
 *
 *  @return New instance of QBMPushMessage
 */
+ (QBMPushMessage *)pushMessage;

@end

NS_ASSUME_NONNULL_END
