//
//  DataManager.m
//  SimpleSample-custom-object-ios
//
//  Created by Ruslan on 9/14/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

@synthesize notes;

+ (instancetype)shared
{
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notes = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}


@end
