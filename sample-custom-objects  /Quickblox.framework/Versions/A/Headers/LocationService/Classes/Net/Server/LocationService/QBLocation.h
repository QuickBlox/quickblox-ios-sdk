//
//  QBLocation.h
//  LocationService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBLocation class delcaration */
/** Overview */
/** This class is the main entry point to work with Quickblox Location module. */

@interface QBLocation : BaseService {
    
}

#pragma mark -
#pragma mark Create GeoData

/** 
 Create geo data 
 
 Type of Result - QBLGeoDataResult
 
 @param geodata An instance of QBLGeoData
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLGeoDataResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)createGeoData:(QBLGeoData *)geodata delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createGeoData:(QBLGeoData *)geodata delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get GeoData with ID

/** 
 Get geo data by ID
 
 Type of Result - QBLGeoDataResult
 
 @param geodataID ID of instance of QBLGeoData that will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLGeoDataResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)geoDataWithID:(NSUInteger)geodataID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)geoDataWithID:(NSUInteger)geodataID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get multiple GeoData

/** 
 Get multiple geo data
 
 Type of Result - QBLGeoDataPagedResult
 
 @param geodataRequest Search request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLGeoDataPagedResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)geoDataWithRequest:(QBLGeoDataGetRequest *)geodataRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)geoDataWithRequest:(QBLGeoDataGetRequest *)geodataRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update GeoData

/** 
 Update geo data 
 
 Type of Result - QBLGeoDataResult
 
 @param geodata An instance of QBLGeoData
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLGeoDataResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)updateGeoData:(QBLGeoData *)geodata delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateGeoData:(QBLGeoData *)geodata delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete GeoData with ID

/** 
 Delete geo data by ID
 
 Type of Result - QBLGeoDataResult
 
 @param geodataID ID of instance of QBLGeoData that will be deleted
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. Upon finish of the request, result will be an instance of QBLGeoDataResult class.  
 */
+ (NSObject<Cancelable> *)deleteGeoDataWithID:(NSUInteger)geodataID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteGeoDataWithID:(NSUInteger)geodataID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete GeoData

/** 
 Delete geo data
 
 Type of Result - QBLGeoDataResult
 
 @param deleteRequest Delete request
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. Upon finish of the request, result will be an instance of QBLGeoDataResult class.  
 */
+ (NSObject<Cancelable> *)deleteGeoDataWithRequest:(QBLGeoDataDeleteRequest *)deleteRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteGeoDataWithRequest:(QBLGeoDataDeleteRequest *)deleteRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;




#pragma mark -
#pragma mark Create Place

/** 
 Create place
 
 Type of Result - QBLPlaceResult
 
 @param data An instance of QBLPlace
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlaceResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)createPlace:(QBLPlace *)place delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createPlace:(QBLPlace *)place delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update Place

/** 
 Update place
 
 Type of Result - QBLPlaceResult
 
 @param data An instance of QBLPlace
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlaceResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)updatePlace:(QBLPlace *)place delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updatePlace:(QBLPlace *)place delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Places

/** 
 Get all places (last 10 places, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBLPlacePagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlacePagedResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)placesWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)placesWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/** 
 Get places with paged request
 
 Type of Result - QBLPlacePagedResult
 
 @param pagedRequest Paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlacePagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)placesWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)placesWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Get Place with ID

/** 
 Get place with ID
 
 Type of Result - QBLPlaceResult
 
 @param placeID ID of instance of QBLPlace that will be retrieved
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlaceResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)placeWithID:(NSUInteger)placeID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)placeWithID:(NSUInteger)placeID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete Place with ID

/** 
 Delete place with ID
 
 Type of Result - QBLPlaceResult
 
 @param placeID ID of instance of QBLPlace that will be deleted
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBLPlaceResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)deletePlaceWithID:(NSUInteger)placeID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deletePlaceWithID:(NSUInteger)placeID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


@end
