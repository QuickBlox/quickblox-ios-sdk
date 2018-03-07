//
//  QBMPushToken.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Quickblox/QBCEntity.h>

NS_ASSUME_NONNULL_BEGIN

/** QBMPushToken class declaration.
 *  Class represents push token, that uniquely identifies the application.  
 *  (for APNS - it's token, for C2DM - it's registration Id, for MPNS - it's uri, for BBPS - it's token).
 */
@interface QBMPushToken : QBCEntity <NSCoding, NSCopying>

/** 
 *  Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.
 */
@property(nonatomic, copy, nullable) NSString *clientIdentificationSequence;

/** 
 *  Set custom UDID or use auto-generated UDID if customUDID is nil.
 */
@property(nonatomic, copy, nullable) NSString *customUDID;

/** 
 *  Create new push token.
 *
 *  @return New instance of QBMPushToken
 */
+ (QBMPushToken *)pushToken;

/** 
 *  Create new push token.
 *
 *  @return New instance of QBMPushToken with custom UDID
 */
+ (QBMPushToken *)pushTokenWithCustomUDID:(nullable NSString *)customUDID;

@end

NS_ASSUME_NONNULL_END
