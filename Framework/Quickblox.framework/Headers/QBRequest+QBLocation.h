//
//  QBRequest+QBLocation.h
//  Quickblox
//
//  Created by QuickBlox team on 12/22/13.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBRequest;
@class QBResponse;
@class QBLGeoData;
@class QBGeneralResponsePage;
@class QBLGeoDataFilter;
@class QBLPlace;

NS_ASSUME_NONNULL_BEGIN

@interface QBRequest (QBLocation)

//MARK: - Create GeoData

/**
 Create geo data
 
 @param geoData An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */

+ (QBRequest *)createGeoData:(QBLGeoData *)geoData
                successBlock:(nullable void (^)(QBResponse *response, QBLGeoData * _Nullable geoData))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - GeoData with ID

/**
 Get geo data by ID
 
 @param geoDataId ID of instance of QBLGeoData that will be retrieved
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */

+ (QBRequest *)geoDataWithId:(NSUInteger)geoDataId
                successBlock:(nullable void (^)(QBResponse *response, QBLGeoData * _Nullable geoData))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - Update GeoData

/**
 Update geo data
 
 @param geodata An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateGeoData:(QBLGeoData *)geodata
                successBlock:(nullable void (^)(QBResponse *response, QBLGeoData * _Nullable geoData))successBlock
                  errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - Delete GeoData with ID

/**
 Delete geo data by ID
 
 @param geodataID ID of instance of QBLGeoData that will be deleted
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteGeoDataWithID:(NSUInteger)geodataID
                      successBlock:(nullable void (^)(QBResponse *response))successBlock
                        errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - Delete GeoData

/**
 Delete geo data with remaining days
 
 @param days Maximum age of data that must remain in the database after a query.
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteGeoDataWithRemainingDays:(NSUInteger)days
                                 successBlock:(nullable void (^)(QBResponse *response))successBlock
                                   errorBlock:(nullable QBRequestErrorBlock)errorBlock;

//MARK: - Get multiple GeoData

/**
 Get multiple geo data
 
 @param filter QBLGeoDataFilter with filter values set
 @param page Requested page
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)geoDataWithFilter:(QBLGeoDataFilter *)filter
                            page:(nullable QBGeneralResponsePage *)page
                    successBlock:(nullable void (^)(QBResponse *response, NSArray<QBLGeoData *> * _Nullable objects, QBGeneralResponsePage * _Nullable page))successBlock
                      errorBlock:(nullable QBRequestErrorBlock)errorBlock;

@end

NS_ASSUME_NONNULL_END
