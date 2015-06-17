//
//  QBMPushToken.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"

/** QBMPushToken class declaration. */
/** Overview */
/** Class represents push token, that uniquely identifies the application.  (for APNS - it's token, for C2DM - it's registration Id, for MPNS - it's uri, for BBPS - it's token). */

@interface QBMPushToken : QBCEntity <NSCoding, NSCopying>{
	NSString *clientIdentificationSequence;
	BOOL isEnvironmentDevelopment;
}

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, retain) NSString *clientIdentificationSequence;

/** Set custom UDID or use auto-generated UDID if customUDID is nil */
@property(nonatomic, retain) NSString *customUDID;

/** Determine application mode. It allows conveniently separate development and production modes. */
@property(nonatomic) BOOL isEnvironmentDevelopment;

/** Create new push token
 @return New instance of QBMPushToken
 */
+ (QBMPushToken *)pushToken;

/** Create new push token
 @return New instance of QBMPushToken with custom UDID
 */
+ (QBMPushToken *)pushTokenWithCustomUDID:(NSString *)customUDID;

@end