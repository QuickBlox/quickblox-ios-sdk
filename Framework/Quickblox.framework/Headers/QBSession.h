//
// Created by Andrey Kozlov on 27/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBUUser;
@class QBASession;

/** QBSession class declaration. */
/** Overview */
/** This class represents session information. */

@interface QBSession : NSObject <NSCoding>

/**
 *  Current session instance.
 *
 *  @return QBSession instance.
 */
+ (QB_NONNULL QBSession *)currentSession;

/**
 *  Start session with details
 *
 *  @param session     QBASession instance, token, applicationID, userID are required fields
 *  @param sessionDate expiration date
 */
- (void)startSessionWithDetails:(QB_NONNULL QBASession *)session expirationDate:(QB_NONNULL NSDate *)sessionDate;

/**
 *  Session user
 */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBUUser *currentUser;

/**
 *  Session details
 */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBASession *sessionDetails;

/**
 *  Session expiration date
 */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSDate *sessionExpirationDate;

/**
 *  Token valid state
 */
@property (nonatomic, readonly, getter=isTokenValid) BOOL tokenValid;


/**
 *  Start session with details
 *  Disables auto create session
 *
 *  @note updateSessionBlock executes synchronously on background thread and you are allowed to execute
 *  synchronous URL request and to block a background thread from executing until you receive updated credentials
 *
 *  @note by the end of updateSessionBlock you should call startSessionWithDetails: with updated credentials
 *
 *  @param session            QBAsession instance
 *  @param updateSessionBlock updateSessionBlock before the end of this block you should call startSessionWithDetails:
 */
- (void)startSessionWithDetails:(QB_NONNULL QBASession *)session updateSessionBlock:(QB_NONNULL dispatch_block_t)updateSessionBlock;

/**
 *  Start updated session with details
 *  Use this method to update session details
 *
 *  @note updateSessionBlock block executes synchronously on background thread and you are allowed to execute
 *  synchronous URL request and to block a background thread from executing until you receive updated credentials
 *
 *  @note call this method after first session start with startSessionWithDetails:updateSessionBlock:
 *  @note updateSessionBlock must be already set
 *
 *  @param session QBAsession instance with updated credentials
 */
- (void)startSessionWithDetails:(QB_NONNULL QBASession *)session;

@end
