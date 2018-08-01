//
//  QBRequest+QBAddressBook.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBRequest.h>

@class QBAddressBookContact;
@class QBAddressBookUpdates;
@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBAddressBook)

typedef void(^qb_response_address_book_block_t)(NSArray<QBAddressBookContact *> *contacts);
typedef void(^qb_response_address_book_updates_block_t)(QBAddressBookUpdates *updates);
typedef void(^qb_response_registered_users_block_t)(NSArray<QBUUser *> *users);

/**
 Retrieves address book contacts for specified user device.
 
 @param udid User's device identifier. If specified - all operations will be in this context. Max length 64 symbols.
 @param successBlock The block to be executed when address book contact items are retrieved.
 @param errorBlock The block to be executed when the request is failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)addressBookWithUdid:(nullable NSString *)udid
                      successBlock:(nullable qb_response_address_book_block_t)successBlock
                        errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Uploads fresh address book (force update).
 
 @param udid User's device identifier. If specified - all operations will be in this context. Max length 64 symbols.
 @param addressBook Set with address book contact items (phone - unique)
 @param force Rewrite mode. If set YES all previous contacts for device context will be replaced by new ones.
 @param successBlock The block to be executed after successfuly address book updates.
 @param errorBlock The block to be executed when the request is failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)uploadAddressBookWithUdid:(nullable NSString *)udid
                             addressBook:(nullable NSOrderedSet<QBAddressBookContact *> *)addressBook
                                   force:(BOOL)force
                            successBlock:(nullable qb_response_address_book_updates_block_t)successBlock
                              errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Retrieves registered users from address book
 
 @param udid User's device identifier. If specified - all operations will be in this context. Max length 64 symbols.
 @param compact if YES - server will return only `id` and `phone` fields of User. Otherwise - all User's fields will be returned.
 @param successBlock The block to be executed when registered users are retrieved.
 @param errorBlock The block to be executed when the request is failed.
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)registeredUsersFromAddressBookWithUdid:(nullable NSString *)udid
                                            isCompact:(BOOL)compact
                                         successBlock:(nullable qb_response_registered_users_block_t)successBlock
                                           errorBlock:(nullable qb_response_block_t)errorBlock;

@end

NS_ASSUME_NONNULL_END
