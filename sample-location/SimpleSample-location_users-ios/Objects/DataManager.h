//
//  DataManager.h
//  SimpleSample-location_users-ios
//
//  Created by Tatyana Akulova on 9/19/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents storage for user's checkins
//

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray *checkinArray;
@property (nonatomic, strong) QBUUser *currentUser;

+ (instancetype) instance;

@end