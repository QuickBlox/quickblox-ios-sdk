//
//  SSLGeoDataManager.h
//  sample-location
//
//  Created by Injoit on 8/27/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLGeoDataManager : NSObject

+ (instancetype)instance;

- (void)fetchLatestCheckIns;

@end
