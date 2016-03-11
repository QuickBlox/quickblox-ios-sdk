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

@end
