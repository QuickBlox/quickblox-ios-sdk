//
//  Alert.m
//  sample-conference-videochat
//
//  Created by Injoit on 20.07.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "Alert.h"

@implementation Alert

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isPresented = NO;
    }
    return self;
}

@end
