//
//  QBError.h
//  Quickblox
//
//  Created by Andrey Moskvin on 8/18/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBError : NSObject

@property (nonatomic, readonly) NSDictionary* reasons;
@property (nonatomic, readonly) NSError* error;

+ (instancetype)errorWithError:(NSError *)error;

@end
