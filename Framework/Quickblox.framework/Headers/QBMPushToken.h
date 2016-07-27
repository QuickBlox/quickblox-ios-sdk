//
//  QBMPushToken.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBCEntity.h"

/** QBMPushToken class declaration. */
/** Overview */
/** Class represents push token, that uniquely identifies the application.  (for APNS - it's token, for C2DM - it's registration Id, for MPNS - it's uri, for BBPS - it's token). */

@interface QBMPushToken : QBCEntity <NSCoding, NSCopying>{
	NSString *clientIdentificationSequence;
}

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *clientIdentificationSequence;

/** Set custom UDID or use auto-generated UDID if customUDID is nil */
@property(nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *customUDID;

/** Create new push token
 @return New instance of QBMPushToken
 */
+ (QB_NONNULL QBMPushToken *)pushToken;

/** Create new push token
 @return New instance of QBMPushToken with custom UDID
 */
+ (QB_NONNULL QBMPushToken *)pushTokenWithCustomUDID:(QB_NULLABLE NSString *)customUDID;

@end