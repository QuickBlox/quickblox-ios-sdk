//
// Created by Andrey Kozlov on 27/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBUUser;
@class QBASession;


@interface QBSession : NSObject

+ (QBSession *)currentSession;

@property (nonatomic, readonly) QBUUser *currentUser;
@property (nonatomic, readonly) QBASession *sessionDetails;
@property (nonatomic, readonly) NSDate *sessionExpirationDate;

@property (nonatomic, readonly) NSString *socialProviderToken;
@property (nonatomic, readonly) NSDate *socialProviderTokenExpirationDate;

@property (nonatomic, readonly, getter=isTokenValid) BOOL tokenValid;

- (void)startSessionWithDetails:(QBASession *)session expirationDate:(NSDate *)sessionDate;
- (void)updateSessionUser:(QBUUser *)user;
- (void)saveSocialProviderDetailsFromHeaders:(NSDictionary *)headers;
- (void)endSession;

@end