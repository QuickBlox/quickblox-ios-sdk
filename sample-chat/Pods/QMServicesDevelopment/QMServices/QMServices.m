//
//  QMServices.m
//  QMServices
//
//  Created by Andrey on 21.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServicesManager.h"

@interface QMServices_lib : NSObject
@end

@implementation QMServices_lib

- (void)main {
    [QMServicesManager instance];
}
@end
