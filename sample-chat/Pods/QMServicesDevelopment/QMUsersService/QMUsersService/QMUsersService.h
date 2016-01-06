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
                       cacheDataSource:(id<QMUsersServiceCacheDataSource>)cacheDataSource;

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
 *  Get users by ids.
 *
 *  @param userIDs  array of user ids
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithIDs:(NSArray QB_GENERIC(NSNumber *) *)usersIDs;

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
 *  Get users by emails.
 *
 *  @param emails   array of user emails
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithEmails:(NSArray QB_GENERIC(NSString *) *)emails;

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
 *  Get users by facebook ids.
 *
 *  @param facebookIDs  array of user facebook ids
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithFacebookIDs:(NSArray QB_GENERIC(NSString *) *)facebookIDs;

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
 *  Get users by logins.
 *
 *  @param logins   array of user logins
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins;

/**
 *  Get users by logins with extended pagination parameters.
 *
 *  @param logins   array of user logins
 *  @param page     QBGeneralResponsePage instance with extended pagination parameters
 *
 *  @return BFTask with NSArray of QBUUser instances as a result
 */
- (BFTask QB_GENERIC(NSArray QB_GENERIC(QBUUser *) *) *)getUsersWithLogins:(NSArray QB_GENERIC(NSString *) *)logins page:(QBGeneralResponsePage *)page;


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
- (void)cachedUsers:(void(^)(NSArray* collection))block;

@end

@protocol QMUsersServiceDelegate <NSObject>

@optional

/**
 *  Is called when users were added to QMUsersService.
 *
 *  @param usersService     QMUsersService instance
 *  @param user             NSArray of QBUUser instances as users
 */
- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray QB_GENERIC(QBUUser *) *)user;

@end
