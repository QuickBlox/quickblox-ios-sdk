//
//  DataManager.h
//  sample-location
//
//  Created by Quickblox Team on 9/19/12.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//
//
// This class presents storage for user's checkins
//

extern NSString * const SSLGeoDataManagerDidUpdateData;

@interface SSLDataManager : NSObject

@property (nonatomic, readonly) NSArray *checkins;
@property (nonatomic, readonly) QBUUser *currentUser;

+ (instancetype)instance;

- (void)saveCheckins:(NSArray *)checkins;
- (void)saveCurrentUser:(QBUUser *)user;

@end