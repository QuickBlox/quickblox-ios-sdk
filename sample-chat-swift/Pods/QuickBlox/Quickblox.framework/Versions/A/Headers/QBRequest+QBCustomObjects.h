//
// Created by Andrey Kozlov on 24/02/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "QBRequest.h"
#import "QBCustomObjectsConsts.h"

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
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)objectWithClassName:(QB_NONNULL NSString *)className
                                           ID:(QB_NONNULL NSString *)ID
                                 successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOCustomObject *QB_NULLABLE_S object))successBlock
                                   errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with IDs

 @param className Name of class
 @param IDs Identifiers of objects to be retrieved
 @param successBlock Block with response instance, NSArray of found objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)objectsWithClassName:(QB_NONNULL NSString *)className
                                           IDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)IDs
                                  successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray *QB_NULLABLE_S objects))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects

 @param className Name of class
 @param successBlock Block with response instance, NSArray of found objects, NSArray of not found objects Ids and QBResponsePage if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)objectsWithClassName:(QB_NONNULL NSString *)className
                                  successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray *QB_NULLABLE_S objects))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with extended Request

 @param className Name of class
 @param extendedRequest Extended set of request parameters. `count` parameter is ignored. To receive count use `countObjectsWithClassName:extendedRequest:successBlock:errorBlock:`
 @param successBlock Block with response instance, NSArray of found objects, NSArray of not found objects Ids and QBResponsePage if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)objectsWithClassName:(QB_NONNULL NSString *)className
                               extendedRequest:(QB_NULLABLE NSMutableDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                                  successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBCOCustomObject *) *QB_NULLABLE_S objects, QBResponsePage *QB_NULLABLE_S page))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Objects aggregated by operator

/**
 *  Returns calculated data for specified objects
 *
 *  @param className           Required. Name of class.
 *  @param aggregationOperator Required. Maximum, minimum, average or summary.
 *  @param fieldName           Required. Field name which will be used for calculation.
 *  @param groupFieldName      Required. Field name for group.
 *  @param extendedRequest     Optional. Extended set of request parameters. `count` parameter is ignored. To receive count use `countObjectsWithClassName:extendedRequest:successBlock:errorBlock:`.
 *  @param successBlock        Block with response instance, NSArray of grouped objects.
 *  @param errorBlock          Block with response instance if request failed.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)objectsWithClassName:(QB_NONNULL NSString *)className
                aggregationOperator:(QBCOAggregationOperator)aggregationOperator
                       forFieldName:(QB_NONNULL NSString *)fieldName
                   groupByFieldName:(QB_NONNULL NSString *)groupFieldName
                    extendedRequest:(QB_NULLABLE NSMutableDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                       successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBCOCustomObject *) *QB_NULLABLE_S objects, QBResponsePage *QB_NULLABLE_S responsePage))successBlock
                         errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Count of objects

/**
 Count of objects with extended Request
 
 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param successBlock Block with response instance and count of objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */

+ (QB_NONNULL QBRequest *)countObjectsWithClassName:(QB_NONNULL NSString *)className
                                    extendedRequest:(QB_NULLABLE NSMutableDictionary QB_GENERIC(NSString *, NSString *) *)extendedRequest
                                       successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSUInteger count))successBlock
                                         errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Create Object

/**
 Create record

 @param object An instance of object that will be created
 @param successBlock Block with response instance and created object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createObject:(QB_NONNULL QBCOCustomObject *)object
                          successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOCustomObject *QB_NULLABLE_S object))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Create

/**
 Create records

 @param objects An array of instances of objects that will be created
 @param className Name of class
 @param successBlock Block with response instance, NSArray of created objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createObjects:(QB_NONNULL NSArray QB_GENERIC(QBCOCustomObject *) *)objects
                              className:(QB_NONNULL NSString *)className
                           successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBCOCustomObject *) *QB_NULLABLE_S objects))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Update Object

/**
 Update record

 @param object An instance of object that will be updated
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateObject:(QB_NONNULL QBCOCustomObject *)object
                          successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOCustomObject *QB_NULLABLE_S object))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Update record with Special update operators

 @param object An instance of object that will be updated
 @param specialUpdateOperators Special update operators http://quickblox.com/developers/SimpleSample-customObjects-ios#Special_update_oparators
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateObject:(QB_NONNULL QBCOCustomObject *)object
                specialUpdateOperators:(QB_NONNULL NSMutableDictionary QB_GENERIC(NSString *, NSString *) *)specialUpdateOperators
                          successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOCustomObject *QB_NULLABLE_S object))successBlock
                            errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Update

/**
 Update records

 @param objects An array of instances of objects that will be updated
 @param className Name of class
 @param successBlock Block with response instance, updated objects and not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateObjects:(QB_NONNULL NSArray QB_GENERIC(QBCOCustomObject *) *)objects
                              className:(QB_NONNULL NSString *)className
                           successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(QBCOCustomObject *) *QB_NULLABLE_S objects, NSArray QB_GENERIC(NSString *) *QB_NULLABLE_S notFoundObjectsIds))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Delete Object

/**
 Delete object by identifier

 @param objectID ID of object to be removed.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteObjectWithID:(QB_NONNULL NSString *)objectID
                                   className:(QB_NONNULL NSString *)className
                                successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response))successBlock
                                  errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Delete objects by IDs

 @param objectsIDs Array of IDs of objects to be removed.
 @param successBlock Block with response instance, NSArray of deleted objects Ids and NSArray of not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteObjectsWithIDs:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)objectsIDs
                                     className:(QB_NONNULL NSString *)className
                                  successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSArray QB_GENERIC(NSString *) *QB_NULLABLE_S deletedObjectsIDs, NSArray QB_GENERIC(NSString *) *QB_NULLABLE_S notFoundObjectsIDs, NSArray QB_GENERIC(NSString *) *QB_NULLABLE_S wrongPermissionsObjectsIDs))successBlock
                                    errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark - Permissions

/**
 Retrieve permissions for object with ID

 @param className Name of class
 @param ID Identifier of object which permissions will be retrieved
 @param successBlock Block with response instance and QBCOPermissions instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)permissionsForObjectWithClassName:(QB_NONNULL NSString *)className
                                                         ID:(QB_NONNULL NSString *)ID
                                               successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOPermissions *QB_NULLABLE_S permissions))successBlock
                                                 errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

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
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)uploadFile:(QB_NONNULL QBCOFile *)file
                           className:(QB_NONNULL NSString *)className
                            objectID:(QB_NONNULL NSString *)objectID
                       fileFieldName:(QB_NONNULL NSString *)fileFieldName
                        successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, QBCOFileUploadInfo *QB_NULLABLE_S info))successBlock
                         statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                          errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Download file

 @param className Name of class
 @param objectID Identifier of object which file will be downloaded
 @param fileFieldName Name of file field
 @param successBlock Block with response instance and NSData instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)downloadFileFromClassName:(QB_NONNULL NSString *)className
                                           objectID:(QB_NONNULL NSString *)objectID
                                      fileFieldName:(QB_NONNULL NSString *)fileFieldName
                                       successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response, NSData *QB_NULLABLE_S loadedData))successBlock
                                        statusBlock:(QB_NULLABLE QBRequestStatusUpdateBlock)statusBlock
                                         errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 Delete file

 @param className Name of class
 @param objectID Identifier of object form which file will be deleted
 @param fileFieldName Name of file field
 @param successBlock Block with response instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteFileFromClassName:(QB_NONNULL NSString *)className
                                         objectID:(QB_NONNULL NSString *)objectID
                                    fileFieldName:(QB_NONNULL NSString *)fileFieldName
                                     successBlock:(QB_NULLABLE void (^)(QBResponse *QB_NONNULL_S response))successBlock
                                       errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

@end