//
//  QBLGeoDataResult.h
//  LocationServices
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/** QBGeoDataResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create geodata. Represent a single geodatum. */

@interface QBLGeoDataResult : Result {
}

/** An instance of QBLGeoData.*/
@property (nonatomic,readonly) QBLGeoData *geoData;

@end
