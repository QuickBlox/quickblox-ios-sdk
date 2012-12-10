//
//  QBMPushToken.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBMPushToken class declaration. */
/** Overview */
/** Class represents push token, that uniquely identifies the application.  (for APNS - it's token, for C2DM - it's registration Id, for MPNS - it's uri, for BBPS - it's token). */

@interface QBMPushToken : Entity <NSCoding, NSCopying>{
	NSString *clientIdentificationSequence;
	BOOL isEnvironmentDevelopment;
}

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, retain) NSString *clientIdentificationSequence;

/** Determine application mode. It allows conveniently separate development and production modes. */
@property(nonatomic) BOOL isEnvironmentDevelopment;

/** Create new push token
 @return New instance of QBMPushToken
 */
+ (QBMPushToken *)pushToken;

@end