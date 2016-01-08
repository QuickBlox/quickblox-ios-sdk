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
@interface QMContactListService : QMBaseService <QMUsersMemoryStorageDelegate>

/**
 *  Memory storage for contact list items.
 */
@property (strong, nonatomic, readonly) QMContactListMemoryStorage *contactListMemoryStorage;

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
- (BFTask *)addUserToContactListRequest:(QBUUser *)user;

/**
 *  Remove user from contact list using Bolts.
 *
 *  @param userID id of user to remove
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)removeUserFromContactListWithUserID:(NSUInteger)userID;

/**
 *  Accept contact request using Bolts.
 *
 *  @param userID id of user to accept contact request
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)acceptContactRequest:(NSUInteger)userID;

/**
 *  Reject contact request for user id using Bolts.
 *
 *  @param userID id of user to reject contact request
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)rejectContactRequest:(NSUInteger)userID;

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
- (void)cachedContactListItems:(QMCacheCollection)block;

@optional

- (void)contactListDidAddUser:(QBUUser *)user;

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
 *  Is called when contact list service did recieve some activity changes of userID
 *
 *  @param userID   id of user
 *  @param isOnline online status for user
 *  @param status   custom status for user
 */
- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status;



@end
