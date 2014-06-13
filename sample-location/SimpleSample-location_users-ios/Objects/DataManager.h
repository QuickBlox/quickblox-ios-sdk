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

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, retain) NSArray *checkinArray;
@property (nonatomic, retain) QBUUser *currentUser;

+ (DataManager *) shared;

@end