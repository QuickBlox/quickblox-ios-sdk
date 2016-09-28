//
//  QBCOFile.h
//  Quickblox
//
//  Created by Igor Khomenko on 10/10/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBCOFile : NSObject <NSCoding, NSCopying>

/** 
 *  File name.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  File content type.
 */
@property (nonatomic, copy, nullable) NSString *contentType;

/**
 *  File data.
 */
@property (nonatomic, strong, nullable) NSData *data;

/** 
 *  Create file object.
 *
 *  @return New instance of QBCOFile
 */
+ (instancetype)file;

@end

NS_ASSUME_NONNULL_END
