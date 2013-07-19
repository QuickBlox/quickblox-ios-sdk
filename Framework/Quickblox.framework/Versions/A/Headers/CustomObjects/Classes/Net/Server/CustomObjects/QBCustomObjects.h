//
//  QBCustomObjects.h
//  Quickblox
//
//  Created by IgorKh on 8/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

/** QBCustomObjects class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Custom Objects module. */

@interface QBCustomObjects : BaseService


#pragma mark -
#pragma mark Get Objects

/**
 Retrieve object with ID
 
 Type of Result - QBCOObjectsResult
 
 @param className Name of class
 @param ID Identifier of object to be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)objectWithClassName:(NSString *)className ID:(NSString *)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)objectWithClassName:(NSString *)className ID:(NSString *)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 Retrieve objects with IDs
 
 Type of Result - QBCOObjectsResult
 
 @param className Name of class
 @param IDs Identifiers of objects to be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className IDs:(NSArray *)IDs delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className IDs:(NSArray *)IDs delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve objects
 
 Type of Result - QBCOObjectsResult
 
 @param className Name of class
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve objects with extended Request
 
 Type of Result - QBCOObjectsResult
 
 @param className Name of class
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)objectsWithClassName:(NSString *)className extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Create Object

/**
 Create record
 
 Type of Result - QBCOObjectResult
 
 @param object An instance of object that will be created
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createObject:(QBCOCustomObject *)object delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createObject:(QBCOCustomObject *)object delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update Object

/**
 Update record
 
 Type of Result - QBCOObjectResult
 
 @param object An instance of object that will be updated
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateObject:(QBCOCustomObject *)object delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateObject:(QBCOCustomObject *)object delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 Update record with Special update operators
 
 Type of Result - QBCOObjectResult
 
 @param object An instance of object that will be updated
 @param specialUpdateOperators Special update operators http://quickblox.com/developers/Custom_Objects#Special_update_operators
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateObject:(QBCOCustomObject *)object specialUpdateOperators:(NSMutableDictionary *)specialUpdateOperators delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateObject:(QBCOCustomObject *)object specialUpdateOperators:(NSMutableDictionary *)specialUpdateOperators delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete Object

/**
 Delete object by identifier
 
 Type of Result - QBCOObjectResult
 
 @param objectID ID of object to be removed.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteObjectWithID:(NSString *)objectID className:(NSString *)className delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteObjectWithID:(NSString *)objectID className:(NSString *)className delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Permissions

/**
 Retrieve permissions for object with ID
 
 Type of Result - QBCOPermissionsResult
 
 @param className Name of class
 @param ID Identifier of object which permissions will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBCOObjectsResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)permissionsForObjectWithClassName:(NSString *)className ID:(NSString *)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)permissionsForObjectWithClassName:(NSString *)className ID:(NSString *)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

@end
