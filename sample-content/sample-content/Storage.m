//
//  Storage.m
//  sample-content
//
//  Created by Quickblox Team on 6/9/15.
//  Copyright (c) 2015 QuickBlox. All rights reserved.
//

#import "Storage.h"

@implementation Storage

+ (instancetype)instance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.filesList = [NSMutableArray array];
    }
    return self;
}


@end
