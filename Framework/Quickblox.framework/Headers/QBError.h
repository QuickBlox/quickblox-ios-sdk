//
//  QBError.h
//  Quickblox
//
//  Created by Andrey Moskvin on 8/18/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBError : NSObject

@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, NSString *) * reasons;
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) NSError* error;

+ (QB_NONNULL instancetype)errorWithError:(QB_NULLABLE NSError *)error;

@end
