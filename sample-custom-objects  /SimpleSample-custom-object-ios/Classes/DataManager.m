//
//  DataManager.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager *dataManager = nil;

@synthesize notes;

+(DataManager *)shared{
    if(!dataManager){
        dataManager = [[DataManager alloc] init];
        dataManager.notes = [[[NSMutableArray alloc] init] autorelease];
    }
    return dataManager;
}

@end
