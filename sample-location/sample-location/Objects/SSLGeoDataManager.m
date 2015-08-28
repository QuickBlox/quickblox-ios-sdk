//
//  SSLGeoDataManager.m
//  sample-location
//
//  Created by Quickblox Team on 8/27/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "SSLGeoDataManager.h"
#import "SSLDataManager.h"
#import "SSLMapPin.h"

@implementation SSLGeoDataManager

+ (instancetype)instance
{
    static SSLGeoDataManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)fetchLatestCheckIns
{
    QBLGeoDataFilter* filter = [QBLGeoDataFilter new];
    filter.lastOnly = YES;
    filter.sortBy = GeoDataSortByKindCreatedAt;
    
    QBGeneralResponsePage *page = [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:70];
    
    [QBRequest geoDataWithFilter:filter
                            page:page
                    successBlock:^(QBResponse *response, NSArray *objects, QBGeneralResponsePage *page) {
                        
                        [[SSLDataManager instance] saveCheckins:objects];
                        
                    } errorBlock:^(QBResponse *response) {
                        
                        NSLog(@"Error = %@", response.error);
                        
                    }];
}

@end
