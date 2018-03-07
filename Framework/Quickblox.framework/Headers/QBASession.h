//
//  QBASession.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBCEntity.h>


NS_ASSUME_NONNULL_BEGIN
/**
 *  QBASession class interface.
 *  This class represents session details.
 */
@interface QBASession : QBCEntity <NSCoding, NSCopying>

/**
 *  Unique auto generated sequence of numbers which identify API User as the legitimate user of our system.
 *  It is used in relatively short periods of time and can be easily changed. We grant API Users some rights
 *  after authentication and check them based on this token.
 */
@property (nonatomic, copy, nullable) NSString *token;

/** 
 *  Application identifier.
 */
@property (nonatomic, assign) NSUInteger applicationID;

/**
 *  User identifier.
 */
@property (nonatomic, assign) NSUInteger userID;

/**
 *  Device identifier.
 */
@property (nonatomic, assign) NSUInteger deviceID;

/**
 *  Unix Timestamp.
 *
 *  @note It shouldn't be differ from time provided by NTP more than 10 minutes. 
 *  We suggest you to synchronize time on your devices with NTP service.
 */
@property (nonatomic, assign) NSUInteger timestamp;

/**
 *  Unique Random Value.
 *
 *  @note Requests with the same timestamp and same value for nonce parameter can not be send twice.
 */
@property (nonatomic, assign) NSInteger nonce;

@end

NS_ASSUME_NONNULL_END
