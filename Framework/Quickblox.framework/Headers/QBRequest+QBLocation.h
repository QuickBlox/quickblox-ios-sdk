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
 
 @return An instance of QBRequest for cancel operation mainly.
*/

+ (QB_NONNULL QBRequest *)createGeoData:(QB_NONNULL QBLGeoData *)geoData
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBLGeoData * QB_NULLABLE_S geoData))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Get GeoData with ID

/**
 Get geo data by ID
 
 @param geoDataId ID of instance of QBLGeoData that will be retrieved
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
*/

+ (QB_NONNULL QBRequest *)geoDataWithId:(NSUInteger)geoDataId
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBLGeoData * QB_NULLABLE_S geoData))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Update GeoData

/**
 Update geo data
 
 @param geodata An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateGeoData:(QB_NONNULL QBLGeoData *)geodata
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBLGeoData * QB_NULLABLE_S geoData))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete GeoData with ID

/**
 Delete geo data by ID
 
 @param geodataID ID of instance of QBLGeoData that will be deleted
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteGeoDataWithID:(NSUInteger)geodataID
                                 successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                   errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete GeoData

/**
 Delete geo data with remaining days
 
 @param days Maximum age of data that must remain in the database after a query.
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteGeoDataWithRemainingDays:(NSUInteger)days
                                            successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                              errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Get multiple GeoData

/**
 Get multiple geo data
 
 @param filter QBLGeoDataFilter with filter values set
 @param page Requested page
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)geoDataWithFilter:(QB_NONNULL QBLGeoDataFilter *)filter
                                       page:(QB_NULLABLE QBGeneralResponsePage *)page
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBLGeoData *) * QB_NULLABLE_S objects, QBGeneralResponsePage * QB_NULLABLE_S page))successBlock
                                 errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

@end
