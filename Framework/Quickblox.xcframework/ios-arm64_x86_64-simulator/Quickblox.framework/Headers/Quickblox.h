//
//  Quickblox.h
//  Quickblox
//
//  Copyright (c) 2016 QuickBlox. All rights reserved.

#import <QuickBlox/QBAddressBookContact.h>
#import <QuickBlox/QBAddressBookRejectDetails.h>
#import <QuickBlox/QBAddressBookUpdates.h>
#import <QuickBlox/QBASession.h>
#import <QuickBlox/QBCBlob.h>
#import <QuickBlox/QBCBlobObjectAccess.h>
#import <QuickBlox/QBCEntity.h>
#import <QuickBlox/QBChat.h>
#import <QuickBlox/QBChatAttachment.h>
#import <QuickBlox/QBChatDelegate.h>
#import <QuickBlox/QBChatDialog.h>
#import <QuickBlox/QBChatMessage.h>
#import <QuickBlox/QBChatTypes.h>
#import <QuickBlox/QBCOCustomObject.h>
#import <QuickBlox/QBCOFile.h>
#import <QuickBlox/QBCOFileUploadInfo.h>
#import <QuickBlox/QBCompletionTypes.h>
#import <QuickBlox/QBContactList.h>
#import <QuickBlox/QBContactListItem.h>
#import <QuickBlox/QBContentEnums.h>
#import <QuickBlox/QBConnection.h>
#import <QuickBlox/QBCOPermissions.h>
#import <QuickBlox/QBCustomObjectsConsts.h>
#import <QuickBlox/QBCustomObjectsEnums.h>
#import <QuickBlox/QBDarwinNotificationCenter.h>
#import <QuickBlox/QBError.h>
#import <QuickBlox/QBGeneralResponsePage.h>
#import <QuickBlox/QBHTTPClient.h>
#import <QuickBlox/QBLoggerEnums.h>
#import <QuickBlox/QBMEvent.h>
#import <QuickBlox/QBMPushMessage.h>
#import <QuickBlox/QBMPushMessageBase.h>
#import <QuickBlox/QBMPushToken.h>
#import <QuickBlox/QBMSubscription.h>
#import <QuickBlox/QBMulticastDelegate.h>
#import <QuickBlox/QBPrivacyItem.h>
#import <QuickBlox/QBPrivacyList.h>
#import <QuickBlox/QBPushNotificationsConsts.h>
#import <QuickBlox/QBPushNotificationsEnums.h>
#import <QuickBlox/QBRequest.h>
#import <QuickBlox/QBRequest+QBAddressBook.h>
#import <QuickBlox/QBRequest+QBAuth.h>
#import <QuickBlox/QBRequest+QBChat.h>
#import <QuickBlox/QBRequest+QBContent.h>
#import <QuickBlox/QBRequest+QBCustomObjects.h>
#import <QuickBlox/QBRequest+QBPushNotifications.h>
#import <QuickBlox/QBRequest+QBUsers.h>
#import <QuickBlox/QBRequestStatus.h>
#import <QuickBlox/QBResponse.h>
#import <QuickBlox/QBResponsePage.h>
#import <QuickBlox/QBSession.h>
#import <QuickBlox/QBSessionManager.h>
#import <QuickBlox/QBSettings.h>
#import <QuickBlox/QBUpdateUserParameters.h>
#import <QuickBlox/QBUUser.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Framework version 2.18.0
FOUNDATION_EXPORT NSString * const QuickbloxFrameworkVersion;

@interface Quickblox : NSObject

+ (void)initWithApplicationId:(NSUInteger)appId
                      authKey:(NSString *)authKey
                   authSecret:(NSString *)authSecret
                   accountKey:(nullable NSString *)accountKey;

+ (void)initWithApplicationId:(NSUInteger)appId
                  accountKey:(nullable NSString *)accountKey;

// Unavailable initializers
+ (id)new NS_UNAVAILABLE;
- (id)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
