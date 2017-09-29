//
// Created by QuickBlox team on 24/02/2014.
// Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequest.h"
#import "QBCustomObjectsConsts.h"

@class QBResponse;
@class QBResponsePage;
@class QBCOCustomObject;
@class QBCOFile;
@class QBCOPermissions;
@class QBCOFileUploadInfo;

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBCustomObjects)

//MARK: - Get Objects

/**
 Retrieve object with ID
 
 @param className Name of class
 @param ID Identifier of object to be retrieved
 @param successBlock Block with response instance and QBCOCustomObject instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)objectWithClassName:(NSString *)className
                                ID:(NSString *)ID
                      successBlock:(nullable void (^)(QBResponse *response, QBCOCustomObject * _Nullable object))successBlock
                        errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Retrieve objects with IDs
 
 @param className Name of class
 @param IDs Identifiers of objects to be retrieved
 @param successBlock Block with response instance, NSArray of found objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className
                                IDs:(NSArray<NSString *> *)IDs
                       successBlock:(nullable void (^)(QBResponse *response, NSArray * _Nullable objects))successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Retrieve objects with extended Request
 
 @param className Name of class
 @param extendedRequest Extended set of request parameters. `count` parameter is ignored. To receive count use `countObjectsWithClassName:extendedRequest:successBlock:errorBlock:`
 @param successBlock Block with response instance, NSArray of found objects, NSArray of not found objects Ids and QBResponsePage if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className
                    extendedRequest:(nullable NSMutableDictionary <NSString *, NSString *> *)extendedRequest
                       successBlock:(nullable void (^)(QBResponse *response, NSArray <QBCOCustomObject *> * _Nullable objects, QBResponsePage * _Nullable page))successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Objects aggregated by operator

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
+ (QBRequest *)objectsWithClassName:(NSString *)className
                aggregationOperator:(QBCOAggregationOperator)aggregationOperator
                       forFieldName:(NSString *)fieldName
                   groupByFieldName:(NSString *)groupFieldName
                    extendedRequest:(nullable NSMutableDictionary<NSString *, NSString *> *)extendedRequest
                       successBlock:(nullable void (^)(QBResponse *response, NSArray<QBCOCustomObject *> * _Nullable objects, QBResponsePage * _Nullable responsePage))successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Count of objects

/**
 Count of objects with extended Request
 
 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param successBlock Block with response instance and count of objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */

+ (QBRequest *)countObjectsWithClassName:(NSString *)className
                         extendedRequest:(nullable NSMutableDictionary<NSString *, NSString *> *)extendedRequest
                            successBlock:(nullable void (^)(QBResponse *response, NSUInteger count))successBlock
                              errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Create Object

/**
 Create record
 
 @param object An instance of object that will be created
 @param successBlock Block with response instance and created object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createObject:(QBCOCustomObject *)object
               successBlock:(nullable void (^)(QBResponse *response, QBCOCustomObject * _Nullable object))successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Multi Create

/**
 Create records
 
 @param objects An array of instances of objects that will be created
 @param className Name of class
 @param successBlock Block with response instance, NSArray of created objects if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createObjects:(NSArray<QBCOCustomObject *> *)objects
                   className:(NSString *)className
                successBlock:(nullable void (^)(QBResponse *response, NSArray<QBCOCustomObject *> * _Nullable objects))successBlock
                  errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Update Object

/**
 Update record
 
 @param object An instance of object that will be updated
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object
               successBlock:(nullable void (^)(QBResponse *response, QBCOCustomObject * _Nullable object))successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Update record with Special update operators
 
 @param object An instance of object that will be updated
 @param specialUpdateOperators Special update operators http://quickblox.com/developers/SimpleSample-customObjects-ios#Special_update_oparators
 @param successBlock Block with response instance and updated object if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object
     specialUpdateOperators:(NSMutableDictionary<NSString *, NSString *> *)specialUpdateOperators
               successBlock:(nullable void (^)(QBResponse *response, QBCOCustomObject * _Nullable object))successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Multi Update

/**
 Update records
 
 @param objects An array of instances of objects that will be updated
 @param className Name of class
 @param successBlock Block with response instance, updated objects and not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateObjects:(NSArray<QBCOCustomObject *> *)objects
                   className:(NSString *)className
                successBlock:(nullable void (^)(QBResponse *response, NSArray<QBCOCustomObject *> * _Nullable objects, NSArray<NSString *> * _Nullable notFoundObjectsIds))successBlock
                  errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Delete Object

/**
 Delete object by identifier
 
 @param objectID ID of object to be removed.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteObjectWithID:(NSString *)objectID
                        className:(NSString *)className
                     successBlock:(nullable qb_response_block_t)successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Delete objects by IDs
 
 @param objectsIDs Array of IDs of objects to be removed.
 @param successBlock Block with response instance, NSArray of deleted objects Ids and NSArray of not found objects Ids if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteObjectsWithIDs:(NSArray<NSString *> *)objectsIDs
                          className:(NSString *)className
                       successBlock:(nullable void (^)(QBResponse *response, NSArray<NSString *> * _Nullable deletedObjectsIDs, NSArray<NSString *> * _Nullable notFoundObjectsIDs, NSArray<NSString *> * _Nullable wrongPermissionsObjectsIDs))successBlock
                         errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Permissions

/**
 Retrieve permissions for object with ID
 
 @param className Name of class
 @param ID Identifier of object which permissions will be retrieved
 @param successBlock Block with response instance and QBCOPermissions instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)permissionsForObjectWithClassName:(NSString *)className
                                              ID:(NSString *)ID
                                    successBlock:(nullable void (^)(QBResponse *response, QBCOPermissions *permissions))successBlock
                                      errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Files

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
+ (QBRequest *)uploadFile:(QBCOFile *)file
                className:(NSString *)className
                 objectID:(NSString *)objectID
            fileFieldName:(NSString *)fileFieldName
             successBlock:(nullable void (^)(QBResponse *response, QBCOFileUploadInfo * _Nullable info))successBlock
              statusBlock:(nullable qb_response_status_block_t)statusBlock
               errorBlock:(nullable qb_response_block_t)errorBlock;

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
+ (QBRequest *)downloadFileFromClassName:(NSString *)className
                                objectID:(NSString *)objectID
                           fileFieldName:(NSString *)fileFieldName
                            successBlock:(nullable void (^)(QBResponse *response, NSData * _Nullable loadedData))successBlock
                             statusBlock:(nullable qb_response_status_block_t)statusBlock
                              errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Download file using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param className Name of class
 @param objectID Identifier of object which file will be downloaded
 @param fileFieldName Name of file field
 @param successBlock Block with response instance and NSData instance if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)backgroundDownloadFileFromClassName:(NSString *)className
                                          objectID:(NSString *)objectID
                                     fileFieldName:(NSString *)fileFieldName
                                      successBlock:(nullable void (^)(QBResponse *response, NSData * _Nullable loadedData))successBlock
                                       statusBlock:(nullable qb_response_status_block_t)statusBlock
                                        errorBlock:(nullable qb_response_block_t)errorBlock;


/**
 Delete file
 
 @param className Name of class
 @param objectID Identifier of object form which file will be deleted
 @param fileFieldName Name of file field
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteFileFromClassName:(NSString *)className
                              objectID:(NSString *)objectID
                         fileFieldName:(NSString *)fileFieldName
                          successBlock:(nullable qb_response_block_t)successBlock
                            errorBlock:(nullable qb_response_block_t)errorBlock;

@end

NS_ASSUME_NONNULL_END
