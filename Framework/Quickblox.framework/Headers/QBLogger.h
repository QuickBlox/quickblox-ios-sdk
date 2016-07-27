//
// Created by Andrey Kozlov on 13/03/2014.
// Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

typedef NS_ENUM(NSUInteger, QBLogLevel) {
    QBLogLevelNothing   =      0,  //  0 - Nothing in Log
    QBLogLevelErrors    = 1 << 0,  //  1 - Can see Errors
    QBLogLevelWarnings  = 1 << 1,  //  2 - Can see Warnings
    QBLogLevelInfo      = 1 << 2,  //  4 - Some Information Loggs
    QBLogLevelNetwork   = 1 << 3,  //  8 - Network Logs
    QBLogLevelDebug     = NSUIntegerMax
};
