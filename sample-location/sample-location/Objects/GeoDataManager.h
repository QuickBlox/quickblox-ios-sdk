//
//  SSLGeoDataManager.h
//  sample-location
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoDataManager : NSObject

+ (instancetype)instance;

- (void)fetchLatestCheckIns;

@end