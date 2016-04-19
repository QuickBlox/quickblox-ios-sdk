//
// Created by Anton Sokolchenko on 9/28/15.
// Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QBUUser+IndexAndColor.h"
#import "UsersDataSource.h"


@implementation QBUUser (IndexAndColor)

- (NSUInteger)index {

    NSUInteger idx = [UsersDataSource.instance indexOfUser:self];
    return idx;
}

- (UIColor *)color {

    UIColor *color = [UsersDataSource.instance colorAtUser:self];
    return color;
}

@end