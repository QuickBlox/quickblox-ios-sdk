//
//  DataManager.h
//  SimpleSample-ratings-ios
//
//  Created by Ruslan on 9/11/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//
//
// This class presents movies storage
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, retain) NSMutableArray *movies;

+(DataManager *)shared;

@end
