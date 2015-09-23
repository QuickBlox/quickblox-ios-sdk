//
//  QMContactsService.h
//  QMServices
//
//  Created by Ivanov A.V on 14/02/2014.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"
#import "QMContactListMemoryStorage.h"
#import "QMUsersMemoryStorage.h"
#import "QBUUser+CustomData.h"

@class QBGeneralResponsePage;

typedef void(^QMCacheCollection)(NSArray *collection);

@protocol QMContactListServiceDelegate;
@protocol QMContactListServiceCacheDataSource;

/**
 *  Service which used for handling users from contact list.
 */
@interface QMContactListService : QMBaseService

/**
 *  Memory storage for contact list items.
 */
@property (strong, nonatomic, readonly) QMContactListMemoryStorage *contactListMemoryStorage;

/**
 *  Memory storage for users items.
 */
@property (strong, nonatomic, readonly) QMUsersMemoryStorage *usersMemoryStorage;


/**
 *  Init with service data delegate and contact list cache protocol.
 *
 *  @param serviceDataDelegate instance confirmed id<QMServiceDataDelegate> protocol
 *  @param cacheDataSource       instance confirmed id<QMContactListServiceCacheDataSource> protocol
 *
 *  @return QMContactListService instance
 */
- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMContactListServiceCacheDataSource>)cacheDataSource;

/**
 *  Add instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)addDelegate:(id <QMContactListServiceDelegate>)delegate;

/**
 *  Remove instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)removeDelegate:(id <QMContactListServiceDelegate>)delegate;

/**
 *  Retrieve users with ids (with extended set of pagination parameters)
 *
 *  @param ids						ids of users which you want to retrieve
 *  @param forceDownload	force download users even if users are already downloaded and exists in cache
 *  @param completion			Block with response, page and users instances if request succeded
 */
- (void)retrieveUsersWithIDs:(NSArray *)ids forceDownload:(BOOL)forceDownload
                  completion:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray * users))completion;

/**
 *  Add user to contact list request
 *
 *  @param user       user which you would like to add to contact list
 *  @param completion completion block
 */
- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion;

/**
 *  Remove user from contact list request
 *
 *  @param userID     user ID which you would like to remove from contact list
 *  @param completion completion block
 */
- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

/**
 *  Accept contact request
 *
 *  @param userID     user ID from which you would like to accept contact request
 *  @param completion completion block
 */
- (void)acceptContactRequest:(NSUInteger)userID completion:(void (^)(BOOL success))completion;

/**
 *  Reject contact request
 *
 *  @param userID     user ID from which you would like to reject contact request
 *  @param completion completion block
 */
- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion;

@end

#pragma mark - Protocols

/**
 *  Data source for QMContactList Service
 */

@protocol QMContactListServiceCacheDataSource <NSObject>
@required

/**
 * Is called when chat service will start. Need to use for inserting initial data QMUsersMemoryStorage
 *
 *  @param block Block for provide QBUUsers collection
 */
- (void)cachedUsers:(QMCacheCollection)block;

/**
 * Is called when chat service will start. Need to use for inserting initial data QMContactListMemoryStorage
 *
 *  @param block Block for provide QBContactListItem collection
 */
- (void)cachedContactListItems:(QMCacheCollection)block;

@end

/**
 *  Actions from QMContactList Service
 */

@protocol QMContactListServiceDelegate <NSObject>
@optional

/**
 * Is called when contact list service did load data from cache data source in memory storage
 */
- (void)contactListServiceDidLoadCache;

/**
 * Is called when contact list service did change some QBContactList item in memory storage
 *
 *  @param contactList updated QBContactList
 */
- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList;

/**
 * Is called when contact list service did add QBUUser item in memory storage
 *
 *  @param user added QBUUser
 */
- (void)contactListService:(QMContactListService *)contactListService didAddUser:(QBUUser *)user;

/**
 * Is called when contact list service did add QBUUser items in memory storage
 *
 *  @param users added QBUUsers items
 */
- (void)contactListService:(QMContactListService *)contactListService didAddUsers:(NSArray *)users;

/**
 * Is called when contact list service did change some QBUUser item in memory storage
 *
 *  @param user updated QBUUser
 */
- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user;

@end