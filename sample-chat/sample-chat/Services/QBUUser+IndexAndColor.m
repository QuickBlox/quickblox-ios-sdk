//
//  ConnectionManager.m
//  Sample-chat
//
//  Created by Andrey Ivanov on 12.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "QBServiceManager.h"

@implementation QBUUser (IndexAndColor)

- (NSUInteger)index {
	NSUInteger idx = [QBServiceManager.instance.usersService indexOfUser:self];
	return idx;
}

- (UIColor *)color {
	UIColor *color = [QBServiceManager.instance.usersService colorForUser:self];
	return color;
}

@end
