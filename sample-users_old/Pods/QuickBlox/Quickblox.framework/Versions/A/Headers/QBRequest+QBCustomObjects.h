//
// Created by Andrey Kozlov on 24/02/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequest.h"

@class QBResponse;
@class QBResponsePage;
@class QBCOCustomObject;
@class QBCOFile;
@class QBCOPermissions;
@class QBCOFileUploadInfo;

@interface QBRequest (QBCustomObjects)

#pragma mark - Get Objects

/**
 Retrieve object with ID

 @param className Name of class
 @param ID Identifier of object to be retrieved
 @param successBlock Block with response instance and QBCOCustomObject instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectWithClassName:(NSString *)className ID:(NSString *)ID successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with IDs

 @param className Name of class
 @param IDs Identifiers of objects to be retrieved
 @param successBlock Block with response instance, NSArray of found objects if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className IDs:(NSArray *)IDs successBlock:(void (^)(QBResponse *response, NSArray *objects))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects

 @param className Name of class
 @param successBlock Block with response instance, NSArray of found objects, NSArray of not found objects Ids and QBResponsePage if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with extended Request

 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param successBlock Block with response instance, NSArray of found objects, NSArray of not found objects Ids and QBResponsePage if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className extendedRequest:(NSMutableDictionary *)extendedRequest successBlock:(void (^)(QBResponse *response, NSArray *objects, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Count of objects

/**
 Count of objects with extended Request
 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param successBlock Block with response instance and count of objects if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */

+ (QBRequest *)countObjectsWithClassName:(NSString *)className extendedRequest:(NSMutableDictionary *)extendedRequest
                            successBlock:(void (^)(QBResponse *response, NSUInteger count))successBlock
                              errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Create Object

/**
 Create record

 @param object An instance of object that will be created
 @param successBlock Block with response instance and created object if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createObject:(QBCOCustomObject *)object successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Create

/**
 Create records

 @param objects An array of instances of objects that will be created
 @param className Name of class
 @param successBlock Block with response instance, NSArray of created objects if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createObjects:(NSArray *)objects className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Update Object

/**
 Update record

 @param object An instance of object that will be updated
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Update record with Special update operators

 @param object An instance of object that will be updated
 @param specialUpdateOperators Special update operators http://quickblox.com/developers/Custom_Objects#Special_update_operators
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object specialUpdateOperators:(NSMutableDictionary *)specialUpdateOperators successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Update

/**
 Update records

 @param objects An array of instances of objects that will be updated
 @param className Name of class
 @param successBlock Block with response instance, updated objects and not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObjects:(NSArray *)objects className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Delete Object

/**
 Delete object by identifier

 @param objectID ID of object to be removed.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteObjectWithID:(NSString *)objectID className:(NSString *)className successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete objects by IDs

 @param objectsIDs Array of IDs of objects to be removed.
 @param successBlock Block with response instance, NSArray of deleted objects Ids and NSArray of not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteObjectsWithIDs:(NSArray *)objectsIDs className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Permissions

/**
 Retrieve permissions for object with ID

 @param className Name of class
 @param ID Identifier of object which permissions will be retrieved
 @param successBlock Block with response instance and QBCOPermissions instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)permissionsForObjectWithClassName:(NSString *)className ID:(NSString *)ID successBlock:(void (^)(QBResponse *response, QBCOPermissions *permissions))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Files

/**
 Upload file

 @param file File
 @param className Name of class
 @param objectID Identifier of object to which file will be uploaded
 @param fileFieldName Name of file field
 @param successBlock Block with response instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)uploadFile:(QBCOFile *)file className:(NSString *)className objectID:(NSString *)objectID
            fileFieldName:(NSString *)fileFieldName
             successBlock:(void (^)(QBResponse *response, QBCOFileUploadInfo* info))successBlock
              statusBlock:(QBRequestStatusUpdateBlock)statusBlock
               errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Download file

 @param className Name of class
 @param objectID Identifier of object which file will be downloaded
 @param fileFieldName Name of file field
 @param successBlock Block with response instance and NSData instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)downloadFileFromClassName:(NSString *)className
                                objectID:(NSString *)objectID
                           fileFieldName:(NSString *)fileFieldName
                            successBlock:(void (^)(QBResponse *response, NSData *loadedData))successBlock
                             statusBlock:(QBRequestStatusUpdateBlock)statusBlock
                              errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete file

 @param className Name of class
 @param objectID Identifier of object form which file will be deleted
 @param fileFieldName Name of file field
 @param successBlock Block with response instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteFileFromClassName:(NSString *)className objectID:(NSString *)objectID fileFieldName:(NSString *)fileFieldName successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

@end