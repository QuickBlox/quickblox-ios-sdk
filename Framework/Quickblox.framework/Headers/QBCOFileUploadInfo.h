//
//  QBCOFileUploadInfo.h
//  Quickblox
//
//  Created by Andrey Moskvin on 8/7/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@interface QBCOFileUploadInfo : NSObject<NSCoding, NSCopying>

@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *fileIdentifier;
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *name;
@property (nonatomic, strong, QB_NULLABLE_PROPERTY) NSString *contentType;

@end
