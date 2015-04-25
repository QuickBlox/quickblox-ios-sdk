//
//  QBRequest+QBLocation.h
//  Quickblox
//
//  Created by Andrey Moskvin on 12/22/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBRequest;
@class QBResponse;
@class QBLGeoData;
@class QBGeneralResponsePage;
@class QBLGeoDataFilter;
@class QBLPlace;

@interface QBRequest (QBLocation)

#pragma mark -
#pragma mark Create GeoData

/**
 Create geo data
 
 @param geoData An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
*/

+ (QBRequest *)createGeoData:(QBLGeoData *)geoData successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get GeoData with ID

/**
 Get geo data by ID
 
 @param geoDataId ID of instance of QBLGeoData that will be retrieved
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
*/

+ (QBRequest *)geoDataWithId:(NSUInteger)geoDataId successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Update GeoData

/**
 Update geo data
 
 @param geodata An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateGeoData:(QBLGeoData *)geodata successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Delete GeoData with ID

/**
 Delete geo data by ID
 
 @param geodataID ID of instance of QBLGeoData that will be deleted
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteGeoDataWithID:(NSUInteger)geodataID successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Delete GeoData

/**
 Delete geo data with remaining days
 
 @param days Maximum age of data that must remain in the database after a query.
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteGeoDataWithRemainingDays:(NSUInteger)days successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Create Place

/**
 Create place
 
 @param place An instance of QBLPlace
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createPlace:(QBLPlace *)place successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Update Place

/**
 Update place
 
 @param place An instance of QBLPlace
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updatePlace:(QBLPlace *)place successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get Place with ID

/**
 Get place with ID
 
 @param placeID ID of instance of QBLPlace that will be retrieved
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)placeWithID:(NSUInteger)placeID successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Delete Place with ID

/**
 Delete place with ID
 
 @param placeID ID of instance of QBLPlace that will be deleted
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deletePlaceWithID:(NSUInteger)placeID successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get multiple GeoData

/**
 Get multiple geo data
 
 @param filter QBLGeoDataFilter with filter values set
 @param page Requested page
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)geoDataWithFilter:(QBLGeoDataFilter *)filter page:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, NSArray* objects, QBGeneralResponsePage* page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

/**
 Get places with paged request
 
 @param page Requested page
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)placesForPage:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, NSArray* objects, QBGeneralResponsePage* page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;

@end
