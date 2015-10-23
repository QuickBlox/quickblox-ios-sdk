//
// Created by Andrey Kozlov on 27/12/2013.
// Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBUUser;
@class QBASession;
@class QBResponse;


@interface QBSession : NSObject <NSCoding>

+ (QB_NONNULL QBSession *)currentSession;

@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBUUser *currentUser;
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBASession *sessionDetails;
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSDate *sessionExpirationDate;

@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSString *socialProviderToken;
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSDate *socialProviderTokenExpirationDate;

@property (nonatomic, readonly, getter=isTokenValid) BOOL tokenValid;

- (void)startSessionWithDetails:(QB_NONNULL QBASession *)session expirationDate:(QB_NONNULL NSDate *)sessionDate;
- (void)updateSessionUser:(QB_NULLABLE QBUUser *)user;
- (void)updateExpirationDate:(QB_NULLABLE NSDate *)newExpirationDate;
- (void)saveSocialProviderDetailsFromHeaders:(QB_NONNULL NSDictionary QB_GENERIC(NSString *, NSString *) *)headers;
- (void)validateWithResponse:(QB_NONNULL QBResponse *)response;
- (void)endSession;

@end