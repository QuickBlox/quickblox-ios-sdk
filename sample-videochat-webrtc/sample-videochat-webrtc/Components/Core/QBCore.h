//
//  QBCore.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 03/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QBNetworkStatus)  {
    
    QBNetworkStatusNotReachable = 0,
    QBNetworkStatusReachableViaWiFi,
    QBNetworkStatusReachableViaWWAN
};

typedef NS_ENUM(NSUInteger, ErrorDomain) {
    
    ErrorDomainSignUp,
    ErrorDomainLogIn,
    ErrorDomainLogOut,
    ErrorDomainChat,
};

typedef void(^QBNetworkStatusBlock)(QBNetworkStatus status);

NS_ASSUME_NONNULL_BEGIN


@class QBCore;

@protocol QBCoreDelegate <NSObject>

@optional

/**
 *  Notifying about successful login.
 *
 *  @param core QBCore instance
 */
- (void)coreDidLogin:(QBCore *)core;

/**
 *  Notifying about successful logout.
 *
 *  @param core QBCore instance
 */
- (void)coreDidLogout:(QBCore *)core;

- (void)core:(QBCore *)core loginStatus:(NSString *)loginStatus;

- (void)core:(QBCore *)core error:(NSError *)error domain:(ErrorDomain)domain;

@end

#define Core [QBCore instance]

@interface QBCore : NSObject

@property (strong, nonatomic, readonly) QBUUser *currentUser;
@property (assign, nonatomic, readonly) BOOL isAuthorized;

@property (copy, nonatomic, nullable)  QBNetworkStatusBlock networkStatusBlock;

+ (instancetype)instance;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - Multicast Delegate

- (void)addDelegate:(id <QBCoreDelegate>)delegate;

#pragma mark - SignUp / Login / Logout

/**
 *  Signup and login
 *
 *  @param fullName User name
 *  @param roomName room name (tag)
 */
- (void)signUpWithFullName:(NSString *)fullName roomName:(NSString *)roomName;

/**
 *  login 
 */
- (void)loginWithCurrentUser;

/**
 *  Clear current profile (Keychain)
 */
- (void)clearProfile;

/**
 *  Logout and remove current user from server
 */
- (void)logout;

#pragma mark - Push Notifications
/**
 *  Create subscription.
 *
 *  @param deviceToken Identifies client device
 */
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

#pragma mark - Reachability
/**
 *  Cheker for internet connection
 */
- (QBNetworkStatus)networkStatus;

@end

NS_ASSUME_NONNULL_END
