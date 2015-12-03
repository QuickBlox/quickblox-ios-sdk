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
