//
//  QBSession.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBUUser;
@class QBASession;

NS_ASSUME_NONNULL_BEGIN

//Posted immediately after logout from quickblox and session destruction;
FOUNDATION_EXPORT NSNotificationName const kQBLogoutNotification;

/**
 QBSession class interface.
 This class represents session information.
 */
@interface QBSession : NSObject <NSCoding>

/** The current session instance. */
@property (nonatomic, strong, readonly, class) QBSession *currentSession;

/** Session user */
@property (nonatomic, readonly, copy, nullable) QBUUser *currentUser;

/** Returns YES if token has expired */
@property (nonatomic, readonly) BOOL tokenHasExpired;

/** Current User ID. If user id > 0 session is write*/
@property (nonatomic, readonly) NSUInteger currentUserID;

/** Session details */
@property (nonatomic, readonly, nullable) QBASession *sessionDetails;

/** Session expiration date */
@property (nonatomic, readonly, nullable) NSDate *sessionExpirationDate;

@end

@interface QBSession (ManualSession)

/**
 Start updated session with details
 Use this method to update session details
 
 @note updateSessionBlock block executes synchronously on background thread and you are allowed to execute
 synchronous URL request and to block a background thread from executing until you receive updated credentials
 
 @note call this method after first session start with startSessionWithDetails:updateSessionBlock:
 @note updateSessionBlock must be already set
 
 @param session QBAsession instance with updated credentials
 @warning *Deprecated in 2.18.*. Use 'startSessionWithToken:' method of QBSessionManager instead.
 */
- (void)startSessionWithDetails:(QBASession *)session
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.18. Use 'startSessionWithToken:' method of QBSessionManager instead.");

/**
 Start session with details

 @param session QBASession instance, token, applicationID, userID are required fields
 @param sessionDate expiration date
 @warning *Deprecated in 2.18.*. Use 'startSessionWithToken:' method of QBSessionManager instead.
 */
- (void)startSessionWithDetails:(QBASession *)session expirationDate:(NSDate *)sessionDate
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.18. Use 'startSessionWithToken:' method of QBSessionManager instead.");

/**
 Start session with details
 Disables auto create session
 
 @note updateSessionBlock executes synchronously on background thread and you are allowed to execute
 synchronous URL request and to block a background thread from executing until you receive updated credentials
 
 @note by the end of updateSessionBlock you should call startSessionWithDetails: with updated credentials
 
 @param session QBAsession instance
 @param updateSessionBlock updateSessionBlock before the end of this block you should call startSessionWithDetails:
 @warning *Deprecated in 2.18.*. Use 'startSessionWithToken:' method of QBSessionManager instead.
 Use 'QBSessionManagerDelegate' callbacks to detect session states.
 */
- (void)startSessionWithDetails:(QBASession *)session updateSessionBlock:(dispatch_block_t)updateSessionBlock
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.18. Use 'startSessionWithToken:' method of QBSessionManager instead.");

@end

NS_ASSUME_NONNULL_END
