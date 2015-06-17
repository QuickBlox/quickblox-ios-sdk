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

+ (QBRequest *)createGeoData:(QBLGeoData *)geoData successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Get GeoData with ID

/**
 Get geo data by ID
 
 @param geoDataId ID of instance of QBLGeoData that will be retrieved
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
*/

+ (QBRequest *)geoDataWithId:(NSUInteger)geoDataId successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Update GeoData

/**
 Update geo data
 
 @param geodata An instance of QBLGeoData
 @param successBlock Block with response and geodata instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateGeoData:(QBLGeoData *)geodata successBlock:(void (^)(QBResponse *response, QBLGeoData *geoData))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete GeoData with ID

/**
 Delete geo data by ID
 
 @param geodataID ID of instance of QBLGeoData that will be deleted
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteGeoDataWithID:(NSUInteger)geodataID successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete GeoData

/**
 Delete geo data with remaining days
 
 @param days Maximum age of data that must remain in the database after a query.
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteGeoDataWithRemainingDays:(NSUInteger)days successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;


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
+ (QBRequest *)geoDataWithFilter:(QBLGeoDataFilter *)filter page:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, NSArray* objects, QBGeneralResponsePage* page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock;




#pragma mark -
#pragma mark Deprecated

/**
 Create place
 
 @warning Deprecated in QB iOS SDK 2.3. The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.
 
 @param place An instance of QBLPlace
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createPlace:(QBLPlace *)place successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.")));

/**
 Update place
 
 @warning Deprecated in QB iOS SDK 2.3. The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.
 
 @param place An instance of QBLPlace
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updatePlace:(QBLPlace *)place successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.")));

/**
 Get place with ID
 
 @warning Deprecated in QB iOS SDK 2.3. The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.
 
 @param placeID ID of instance of QBLPlace that will be retrieved
 @param successBlock Block with response and place instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)placeWithID:(NSUInteger)placeID successBlock:(void (^)(QBResponse *response, QBLPlace* place))successBlock errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.")));

/**
 Delete place with ID
 
 @warning Deprecated in QB iOS SDK 2.3. The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.
 
 @param placeID ID of instance of QBLPlace that will be deleted
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deletePlaceWithID:(NSUInteger)placeID successBlock:(void (^)(QBResponse *response))successBlock errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.")));

/**
 Get places with paged request
 
 @warning Deprecated in QB iOS SDK 2.3. The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.
 
 @param page Requested page
 @param successBlock Block with response instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)placesForPage:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, NSArray* objects, QBGeneralResponsePage* page))successBlock errorBlock:(QBRequestErrorBlock)errorBlock __attribute__((deprecated("The Places API along with associated documentation and code samples has been deprecated and is no longer maintained. We no longer provide support for this module, nor do we encourage its use in your project. We suggest that in order to achieve similar functionality, you use the Custom Objects module.")));

@end
