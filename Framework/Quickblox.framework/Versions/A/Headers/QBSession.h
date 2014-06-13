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
@property (nonatomic, readonly) NSDate *sessionExparationDate;

@property (nonatomic, readonly) NSString *socialProviderToken;
@property (nonatomic, readonly) NSDate *socialProviderTokenExparationDate;

@property (nonatomic, readonly, getter=isTokenValid) BOOL tokenValid;

- (void)startSessionWithDetails:(QBASession *)session exparationDate:(NSDate *)sessionDate;
- (void)startSessionForUser:(QBUUser *)user withDetails:(QBASession *)session exparationDate:(NSDate *)sessionDate;
- (void)endSession;

@end