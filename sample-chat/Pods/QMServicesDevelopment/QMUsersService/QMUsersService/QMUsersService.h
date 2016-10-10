//
//  QMUsersService.h
//  QMUsersService
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"
#import "QMUsersMemoryStorage.h"

@protocol QMUsersServiceDelegate;
@protocol QMUsersServiceCacheDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface QMUsersService : QMBaseService

/**
 *  Memory storage for users items.
 */
@property (strong, nonatomic, readonly) QMUsersMemoryStorage *usersMemoryStorage;

/**
 *  Init with service data delegate and users cache protocol.
 *
 *  @param serviceDataDelegate   instance confirmed id<QMServiceDataDelegate> protocol
 *  @param cacheDataSource       instance confirmed id<QMUsersServiceCacheDataSource> protocol
 *
 *  @return QMUsersService instance
 */
- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(nullable id<QMUsersServiceCacheDataSource>)cacheDataSource;

/**
 *  Add instance that confirms users service multicaste protocol.
 *
 *  @param delegate instance that confirms id<QMUsersServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMUsersServiceDelegate>)delegate;

/**
 *  Remove instance that confirms users service multicaste protocol.
 *
 *  @param delegate instance that confirms id<QMUsersServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMUsersServiceDelegate>)delegate;

#pragma mark - Tasks

/**
 *  Load users to memory storage from disc cache.
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)loadFromCache;

#pragma mark - Intelligent fetch

/**
 *  Get user by id.
 *
 *  @param userID   id of user to retreive
 *
 *  @return BFTask with QBUUser as a result
 */
- (BFTask QB_GENERIC(QBUUser *) *)getUserWithID:(NSUInteger)userID;

/**
 *  Get user by id.
 *
 *  @param userID       id of user to retreive
 *  @param forceLoad    whether user should be loaded from server even when he is already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update user in cache by loading him from server.
 *
 *  @return BFTask with QBUUser as a result
 */
- (BFTask QB_GENERIC(QBUUser *) *)getUserWithID:(NSUInteger)userID forceLoad:(BOOL)forceLoad;

/**
 *  Get users by ids.
 *
 *  @param userIDs  array of user ids
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)usersIDs;

/**
 *  Get users by ids.
 *
 *  @param userIDs      array of user ids
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)usersIDs forceLoad:(BOOL)forceLoad;

/**
 *  Get users by ids with extended pagination parameters.
 *
 *  @param userIDs  array of user ids
 *  @param page     QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)usersIDs page:(QBGeneralResponsePage *)page;

/**
 *  Get users by ids with extended pagination parameters.
 *
 *  @param userIDs      array of user ids
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)usersIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad;

/**
 *  Get user with
 *
 *  @param externalUserID external user ID
 *
 *  @return BFTask with user as a result.
 */
- (BFTask QB_GENERIC(QBUUser *) *)getUserWithExternalID:(NSUInteger)externalUserID;

/**
 *  Get user with
 *
 *  @param externalUserID external user ID
 *  @param forceLoad      whether user should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update user in cache by loading him from server.
 *
 *  @return BFTask with user as a result.
 */
- (BFTask QB_GENERIC(QBUUser *) *)getUserWithExternalID:(NSUInteger)externalUserID forceLoad:(BOOL)forceLoad;

/**
 *  Get users by emails.
 *
 *  @param emails   array of user emails
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails;

/**
 *  Get users by emails.
 *
 *  @param emails       array of user emails
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails forceLoad:(BOOL)forceLoad;

/**
 *  Get users by emails with extended pagination parameters.
 *
 *  @param emails   array of user emails
 *  @param page     QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails page:(QBGeneralResponsePage *)page;

/**
 *  Get users by emails with extended pagination parameters.
 *
 *  @param emails       array of user emails
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad;

/**
 *  Get users by facebook ids.
 *
 *  @param facebookIDs  array of user facebook ids
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs;

/**
 *  Get users by facebook ids.
 *
 *  @param facebookIDs  array of user facebook ids
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs forceLoad:(BOOL)forceLoad;

/**
 *  Get users by facebook ids with extended pagination parameters.
 *
 *  @param facebookIDs  array of user facebook ids
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs page:(QBGeneralResponsePage *)page;

/**
 *  Get users by facebook ids with extended pagination parameters.
 *
 *  @param facebookIDs  array of user facebook ids
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad;

/**
 *  Get users by twitter ids.
 *
 *  @param twitterIDs array of user twitter ids
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs;

/**
 *  Get users by twitter ids.
 *
 *  @param twitterIDs array of user twitter ids
 *  @param forceLoad  whether users should be loaded from server even when they are already existing in cache
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs forceLoad:(BOOL)forceLoad;

/**
 *  Get users by twitter ids with extended pagination parameters.
 *
 *  @param twitterIDs array of user twitter ids
 *  @param page       QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs page:(QBGeneralResponsePage *)page;

/**
 *  Get users by twitter ids with extended pagination parameters.
 *
 *  @param twitterIDs array of user twitter ids
 *  @param page       QBGeneralResponsePage instance with extended pagination parameters
 *  @param forceLoad  whether users should be loaded from server even when they are already existing in cache
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithTwitterIDs:(NSArray QB_GENERIC(NSString *) *)twitterIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad;

/**
 *  Get users by logins.
 *
 *  @param logins   array of user logins
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Get users by logins.
 *
 *  @param logins       array of user logins
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins forceLoad:(BOOL)forceLoad;

/**
 *  Get users by logins with extended pagination parameters.
 *
 *  @param logins   array of user logins
 *  @param page     QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins page:(QBGeneralResponsePage *)page;

/**
 *  Get users by logins with extended pagination parameters.
 *
 *  @param logins       array of user logins
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *  @param forceLoad    whether users should be loaded from server even when they are already existing in cache
 *
 *  @discussion Use forceLoad flag if you want to update users in cache by loading them from server.
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad;


#pragma mark - Search

/**
 *  Search for users by full name.
 *
 *  @param searchText   user full name
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithFullName:(NSString *)searchText;

/**
 *  Search for users by full name with extended pagination parameters.
 *
 *  @param searchText   user full name
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithFullName:(NSString *)searchText page:(QBGeneralResponsePage *)page;

/**
 *  Search for users by tags.
 *
 *  @param tags   array of user tags
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithTags:(NSArray QB_GENERIC(NSString *) *)tags;

/**
 *  Search for users by tags with extended pagination parameters.
 *
 *  @param tags   array of user tags
 *  @param page   QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithTags:(NSArray QB_GENERIC(NSString *) *)tags page:(QBGeneralResponsePage *)page;

/**
 *  Search for users by phone numbers.
 *
 *  @param phoneNumbers   array of user phone numbers
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithPhoneNumbers:(NSArray QB_GENERIC(NSString *) *)phoneNumbers;

/**
 *  Search for users by phone numbers with extended pagination parameters.
 *
 *  @param phoneNumbers array of user phone numbers
 *  @param page         QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)searchUsersWithPhoneNumbers:(NSArray QB_GENERIC(NSString *) *)phoneNumbers page:(QBGeneralResponsePage *)page;

@end

#pragma mark - Protocols

/**
 *  Data source for QMUsersService
 */

@protocol QMUsersServiceCacheDataSource <NSObject>
@required

/**
 *  Is called when users service will start. Need to use for inserting initial data QMUsersMemoryStorage.
 *
 *  @param block Block for provide QBUUsers collection
 */
- (void)cachedUsersWithCompletion:(nullable void(^)(NSArray * _Nullable collection))block;

@end

@protocol QMUsersServiceDelegate <NSObject>

@optional

/**
 *  Is called when users were loaded from cache to memory storage
 *
 *  @param usersService QMUsersService instance
 *  @param users        NSArray of QBUUser instances as users
 */
- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray QB_GENERIC(QBUUser *) *)users;

/**
 *  Is called when users were added to QMUsersService.
 *
 *  @param usersService     QMUsersService instance
 *  @param users            NSArray of QBUUser instances as users
 */
- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

/**
 *  Is called when users were updated in cache by forcing its load from server.
 *
 *  @param usersService     QMUsersService instance
 *  @param users            NSArray of QBUUser instances as users
 */
- (void)usersService:(QMUsersService *)usersService didUpdateUsers:(NSArray QB_GENERIC(QBUUser *) *)users;

@end

NS_ASSUME_NONNULL_END
