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

@interface QBRequest (QBCustomObjects)

#pragma mark - Get Objects

/**
 Retrieve object with ID

 @param className Name of class
 @param ID Identifier of object to be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectWithClassName:(NSString *)className ID:(NSString *)ID successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with IDs

 @param className Name of class
 @param IDs Identifiers of objects to be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className IDs:(NSArray *)IDs successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects

 @param className Name of class
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Retrieve objects with extended Request

 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)objectsWithClassName:(NSString *)className extendedRequest:(NSMutableDictionary *)extendedRequest successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Create Object

/**
 Create record

 @param object An instance of object that will be created
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)createObject:(QBCOCustomObject *)object successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Create

/**
 Create records

 @param objects An array of instances of objects that will be created
 @param className Name of class
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)createObjects:(NSArray *)objects className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Update Object

/**
 Update record

 @param object An instance of object that will be updated
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Update record with Special update operators

 @param object An instance of object that will be updated
 @param specialUpdateOperators Special update operators http://quickblox.com/developers/Custom_Objects#Special_update_operators
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObject:(QBCOCustomObject *)object specialUpdateOperators:(NSMutableDictionary *)specialUpdateOperators successBlock:(void (^)(QBResponse *response, QBCOCustomObject *object))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Multi Update

/**
 Update records

 @param objects An array of instances of objects that will be updated
 @param className Name of class
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOCustomObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateObjects:(NSArray *)objects className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds, QBResponsePage *page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Delete Object

/**
 Delete object by identifier

 @param objectID ID of object to be removed.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteObjectWithID:(NSString *)objectID className:(NSString *)className successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete objects by IDs

 @param objectsIDs Array of IDs of objects to be removed.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOMultiDeleteResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteObjectsWithIDs:(NSArray *)objectsIDs className:(NSString *)className successBlock:(void (^)(QBResponse *response, NSArray *deletedObjectsIDs, NSArray *notFoundObjectsIDs, NSArray *wrongPermissionsObjectsIDs))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Permissions

/**
 Retrieve permissions for object with ID

 @param className Name of class
 @param ID Identifier of object which permissions will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOPermissionsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)permissionsForObjectWithClassName:(NSString *)className ID:(NSString *)ID successBlock:(void (^)(QBResponse *response, QBCOPermissions *permissions))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark - Files

/**
 Upload file

 @param file File
 @param className Name of class
 @param objectID Identifier of object to which file will be uploaded
 @param fileFieldName Name of file field
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)uploadFile:(QBCOFile *)file className:(NSString *)className objectID:(NSString *)objectID fileFieldName:(NSString *)fileFieldName successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Download file

 @param className Name of class
 @param objectID Identifier of object which file will be downloaded
 @param fileFieldName Name of file field
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOFileDownloadResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)downloadFileFromClassName:(NSString *)className objectID:(NSString *)objectID fileFieldName:(NSString *)fileFieldName successBlock:(void (^)(QBResponse *response, NSData *loadedData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Delete file

 @param className Name of class
 @param objectID Identifier of object form which file will be deleted
 @param fileFieldName Name of file field
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of Result class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteFileFromClassName:(NSString *)className objectID:(NSString *)objectID fileFieldName:(NSString *)fileFieldName successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

@end