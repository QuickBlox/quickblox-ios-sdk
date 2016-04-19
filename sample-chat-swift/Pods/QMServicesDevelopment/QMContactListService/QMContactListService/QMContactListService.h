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

typedef void(^QMCacheCollection)(NSArray *QB_NULLABLE_S collection);

@protocol QMContactListServiceDelegate;
@protocol QMContactListServiceCacheDataSource;


/**
 *  Service which used for handling users from contact list.
 */
@interface QMContactListService : QMBaseService <QMUsersMemoryStorageDelegate>

/**
 *  Memory storage for contact list items.
 */
@property (strong, nonatomic, readonly, QB_NONNULL) QMContactListMemoryStorage *contactListMemoryStorage;

/**
 *  Init with service data delegate and contact list cache protocol.
 *
 *  @param serviceDataDelegate instance confirmed id<QMServiceDataDelegate> protocol
 *  @param cacheDataSource       instance confirmed id<QMContactListServiceCacheDataSource> protocol
 *
 *  @return QMContactListService instance
 */
- (QB_NULLABLE instancetype)initWithServiceManager:(QB_NONNULL id<QMServiceManagerProtocol>)serviceManager
                                   cacheDataSource:(QB_NULLABLE id<QMContactListServiceCacheDataSource>)cacheDataSource;

/**
 *  Add instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)addDelegate:(QB_NONNULL id <QMContactListServiceDelegate>)delegate;

/**
 *  Remove instance that confirms contact list service multicaste protocol
 *
 *  @param delegate instance that confirms id<QMContactListServiceDelegate> protocol
 */
- (void)removeDelegate:(QB_NONNULL id <QMContactListServiceDelegate>)delegate;

/**
 *  Add user to contact list request
 *
 *  @param user       user which you would like to add to contact list
 *  @param completion completion block
 */
- (void)addUserToContactListRequest:(QB_NONNULL QBUUser *)user completion:(void(^QB_NULLABLE_S)(BOOL success))completion;

/**
 *  Remove user from contact list request
 *
 *  @param userID     user ID which you would like to remove from contact list
 *  @param completion completion block
 */
- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^QB_NULLABLE_S)(BOOL success))completion;

/**
 *  Accept contact request
 *
 *  @param userID     user ID from which you would like to accept contact request
 *  @param completion completion block
 */
- (void)acceptContactRequest:(NSUInteger)userID completion:(void (^QB_NULLABLE_S)(BOOL success))completion;

/**
 *  Reject contact request
 *
 *  @param userID     user ID from which you would like to reject contact request
 *  @param completion completion block
 */
- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^QB_NULLABLE_S)(BOOL success))completion;

@end

#pragma mark - Bolts

/**
 *  Bolts methods for QMContactListService
 */
@interface QMContactListService (Bolts)

/**
 *  Add user to contact list request using Bolts.
 *
 *  @param user user to add to contact list
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)addUserToContactListRequest:(QB_NONNULL QBUUser *)user;

/**
 *  Remove user from contact list using Bolts.
 *
 *  @param userID id of user to remove
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)removeUserFromContactListWithUserID:(NSUInteger)userID;

/**
 *  Accept contact request using Bolts.
 *
 *  @param userID id of user to accept contact request
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)acceptContactRequest:(NSUInteger)userID;

/**
 *  Reject contact request for user id using Bolts.
 *
 *  @param userID id of user to reject contact request
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (QB_NONNULL BFTask *)rejectContactRequest:(NSUInteger)userID;

@end

#pragma mark - Protocols

/**
 *  Data source for QMContactList Service
 */

@protocol QMContactListServiceCacheDataSource <NSObject>
@required

/**
 * Is called when chat service will start. Need to use for inserting initial data QMContactListMemoryStorage
 *
 *  @param block Block for provide QBContactListItem collection
 */
- (void)cachedContactListItems:(QB_NULLABLE QMCacheCollection)block;

@optional

- (void)contactListDidAddUser:(QB_NONNULL QBUUser *)user;

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
- (void)contactListService:(QB_NONNULL QMContactListService *)contactListService contactListDidChange:(QB_NONNULL QBContactList *)contactList;

/**
 *  Is called when contact list service did recieve some activity changes of userID
 *
 *  @param userID   id of user
 *  @param isOnline online status for user
 *  @param status   custom status for user
 */
- (void)contactListService:(QB_NONNULL QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(QB_NULLABLE NSString *)status;

@end
